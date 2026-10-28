local module_path = "lua\\pro_comment_format.lua"
local config_reads = 0
local log_count = 0
local output

log = { info = function() log_count = log_count + 1 end }
yield = function(candidate) output[#output + 1] = candidate end

local function new_env(settings, delimiter)
    local config = {}
    function config:get_map()
        config_reads = config_reads + 1
        return settings
    end
    function config:get_bool(path)
        config_reads = config_reads + 1
        return settings and settings[path:match("[^/]+$")]
    end
    function config:get_string(path)
        config_reads = config_reads + 1
        if path == "speller/delimiter" then return delimiter or " '" end
        return settings and settings[path:match("[^/]+$")]
    end
    return { engine = { schema = { config = config } } }
end

local function candidate(text, comment, kind)
    return {
        text = text, comment = comment, type = kind or "phrase",
        get_genuine = function(self) return self end
    }
end

local function run(filter, env, candidates)
    output = {}
    filter.func({
        iter = function()
            local index = 0
            return function()
                index = index + 1
                return candidates[index]
            end
        end
    }, env)
    assert(#output == #candidates, "candidate count changed")
    for i, cand in ipairs(candidates) do
        assert(output[i] == cand, "candidate identity/order changed")
    end
    return output
end

local filter = dofile(module_path)
assert(type(filter.init) == "function", "Rime init hook is missing")

local env = new_env(nil)
filter.init(env)
assert(filter.CR.corrections == nil, "disabled correction table was initialized")
local initial_reads, initial_logs = config_reads, log_count
for _ = 1, 100 do
    local candidates = {
        candidate("word", "ab*"), candidate("sentence", "cd", "sentence"),
        candidate("completion", "ef", "completion")
    }
    run(filter, env, candidates)
    assert(candidates[1].comment == "ab*")
    assert(candidates[2].comment == "cd")
    assert(candidates[3].comment == "ef")
end
assert(config_reads == initial_reads, "refresh reread configuration")
assert(log_count == initial_logs, "refresh repeated initialization logging")

local function settings(fuzhu, corrector, style, kind, length)
    return {
        fuzhu_code = fuzhu, corrector = corrector,
        corrector_type = style, fuzhu_type = kind,
        candidate_length = length
    }
end

-- Compare with the pre-change module when supplied by the test runner.
local baseline = BASELINE_SOURCE and assert(load(BASELINE_SOURCE))()
local cases = 0
for _, fuzhu in ipairs({ false, true }) do
    for _, corrector in ipairs({ false, true }) do
        for _, kind in ipairs({ "moqi", "flypy", "zrm", "jdh", "cj", "tiger", "wubi", "hx", "unknown" }) do
            for _, length in ipairs({ "0", "1", "3" }) do
                local cfg = settings(fuzhu, corrector, "[{comment}]", kind, length)
                local current_env = new_env(cfg)
                filter.init(current_env)
                local reads = config_reads
                local candidates = {
                    candidate("你", "ni;ab;cd;ef;gh;ij;kl;mn;op;"),
                    candidate("给予", "gei;aa;bb; yu;cc;dd;"),
                    candidate("long word", "unmatched"),
                    candidate("completion", "keep", "completion"),
                    candidate("empty", "")
                }
                local expected = {
                    fuzhu and tonumber(length) >= 1 and
                        ({ moqi = "ab", flypy = "cd", zrm = "ef", jdh = "gh",
                           cj = "ij", tiger = "kl", wubi = "mn", hx = "op" })[kind] or "",
                    corrector and "[jǐ yǔ]" or
                        (fuzhu and tonumber(length) >= 2 and
                            ({ moqi = "aa/cc", flypy = "bb/dd" })[kind] or ""),
                    "", "keep", ""
                }
                run(filter, current_env, candidates)
                assert(config_reads == reads, "configured refresh reread configuration")
                for i, cand in ipairs(candidates) do
                    assert(cand.comment == expected[i],
                        string.format("unexpected comment: case %d, candidate %d: %s", cases, i, cand.comment))
                end
                if baseline then
                    local old = {}
                    for i, cand in ipairs(candidates) do
                        old[i] = candidate(cand.text,
                            ({ "ni;ab;cd;ef;gh;ij;kl;mn;op;", "gei;aa;bb; yu;cc;dd;",
                               "unmatched", "keep", "" })[i], cand.type)
                    end
                    run(baseline, new_env(cfg), old)
                    for i, cand in ipairs(candidates) do
                        assert(cand.comment == old[i].comment, "baseline output differs")
                    end
                end
                cases = cases + 1
            end
        end
    end
end

local first = new_env(settings(false, true, "A{comment}"))
local second = new_env(settings(false, true, "B{comment}"))
filter.init(first)
filter.init(second)
local first_candidates = { candidate("给予", "gei yu") }
local second_candidates = { candidate("给予", "gei yu") }
run(filter, first, first_candidates)
run(filter, second, second_candidates)
assert(first_candidates[1].comment == "Ajǐ yǔ", "schema settings leaked")
assert(second_candidates[1].comment == "Bjǐ yǔ", "schema settings leaked")

local custom_delimiter = new_env(settings(false, true, "{comment}"), "|")
filter.init(custom_delimiter)
local custom_candidates = { candidate("给予", "gei|yu") }
run(filter, custom_delimiter, custom_candidates)
assert(custom_candidates[1].comment == "jǐ yǔ", "custom delimiter changed")
run(filter, env, {})

print(string.format("PASS: %d setting combinations, passthrough, init-only reads, schema isolation%s",
    cases, baseline and ", baseline equivalence" or ""))

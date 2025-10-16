-- === Config ===
local my_last = "Maitland"
local mentee_lastnames = { "Barrus" }  -- add more last names if needed

-- Replace a single inline at index i with a list of inlines
local function replace_one(inlines, i, repl)
  table.remove(inlines, i)
  for k = #repl, 1, -1 do table.insert(inlines, i, repl[k]) end
end

-- Try to style a last-name token with optional star and punctuation in the SAME Str:
-- matches: "Maitland", "Maitland,", "Maitland*," etc.
local function style_packed_lastname(str_inline, target, styler)
  if str_inline.t ~= "Str" then return nil end
  local s = str_inline.text
  -- capture: base(lastname), optional "*", optional punctuation (comma/semicolon/colon/period)
  local base, star, punct = s:match("^("..target..")(%*?)([,;:.]?)$")
  if not base then return nil end

  local repl = { styler(base) }
  if star ~= "" then table.insert(repl, pandoc.Str(star)) end
  if punct ~= "" then table.insert(repl, pandoc.Str(punct)) end
  return repl
end

-- Try to style when punctuation is a SEPARATE token: ["Maitland"][","]
local function style_split_lastname(inlines, i, target, styler)
  local a, b = inlines[i], inlines[i+1]
  if not (a and a.t == "Str" and a.text == target) then return nil end
  -- next could be Space or punctuation or nothing
  if b and b.t == "Str" and b.text:match("^%*$") then
    -- handle "Maitland" + "*" (star) possibly followed by punctuation as another Str
    local repl = { styler(target) }
    table.remove(inlines, i+1) -- drop the star from position i+1
    table.insert(repl, pandoc.Str("*"))
    return repl
  elseif b and b.t == "Str" and b.text:match("^[,;:.]$") then
    -- "Maitland" then ","
    return { styler(target), b } -- keep comma unstyled
  else
    return { styler(target) }
  end
end

-- Stylers
local function bold_last(txt) return pandoc.Strong{ pandoc.Str(txt) } end
local function underline_last(txt)
  if FORMAT:match("latex") then
    return pandoc.RawInline('latex', '\\underline{'..txt..'}')
  else
    return pandoc.RawInline('html', '<u>'..tx




local Localization = {}
Localization.__index = Localization

function Localization.new(config)
  local self = setmetatable({}, Localization)
  self.Enabled = config and config.Enabled ~= false
  self.Prefix = (config and config.Prefix) or "loc:"
  self.DefaultLanguage = (config and config.DefaultLanguage) or "en"
  self.Translations = (config and config.Translations) or { en = {} }
  self.Language = self.DefaultLanguage
  return self
end

function Localization:SetLanguage(lang)
  self.Language = lang or self.DefaultLanguage
end

function Localization:Translate(text)
  if not self.Enabled or type(text) ~= "string" then
    return text
  end
  if not text:find("^" .. self.Prefix) then
    return text
  end
  local token = text:gsub("^" .. self.Prefix, "")
  local source = self.Translations[self.Language] or self.Translations[self.DefaultLanguage] or {}
  return source[token] or token
end

return Localization

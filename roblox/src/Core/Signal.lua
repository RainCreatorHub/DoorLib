local Signal = {}
Signal.__index = Signal

function Signal.new()
  local self = setmetatable({}, Signal)
  self._connections = {}
  return self
end

function Signal:Connect(handler)
  local connection = { Connected = true }
  function connection:Disconnect()
    self.Connected = false
  end
  table.insert(self._connections, { conn = connection, fn = handler })
  return connection
end

function Signal:Once(handler)
  local connection
  connection = self:Connect(function(...)
    if connection and connection.Connected then
      connection:Disconnect()
      handler(...)
    end
  end)
  return connection
end

function Signal:Fire(...)
  for _, pair in ipairs(self._connections) do
    if pair.conn.Connected then
      local ok, err = pcall(pair.fn, ...)
      if not ok then warn("Signal handler error:", err) end
    end
  end
end

function Signal:DisconnectAll()
  for _, pair in ipairs(self._connections) do
    pair.conn.Connected = false
  end
  self._connections = {}
end

return Signal

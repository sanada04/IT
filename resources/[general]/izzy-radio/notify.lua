local Framework, frameworkName = getFramework()

function notify(message)
    if frameworkName == "esx" then
		Framework.ShowNotification(getMessage(message))
	else
		Framework.Functions.Notify(getMessage(message))
	end
end

function getMessage(message)
    return Config.Locale[message]
end
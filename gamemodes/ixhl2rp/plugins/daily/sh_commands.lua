ix.command.Add("CharDailyReset", {
    description = "Resets daily tasks of a player",
    superAdminOnly = true,
    arguments = ix.type.character,
    OnRun = function(self, client, target)
       if target then target:DailyStatus(PLUGIN.globalDailyTime or os.time()) end
    end
})
-- Base Configuration

hvt = hvt or {}

hvt.Config = {
  Author = "Doctor Jew",
  Version = "0.2.0",
  Groups = {
    ["Helicopters"] = {
      Classes = { "wac_hc_blackhawk_uh60", "wac_hc_ch47_chinook", "wac_hc_littlebird_mh6", "wac_hc_uh1y_venom" },
      Delay = 30
    },
    ["NPCs"] = {
      CustomCheck = function(ent)
        return ent:IsNPC()
      end
    }
  }
}

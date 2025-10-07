class ForcedLevelMut extends Mutator
    config(KFForcedLevelV2);

var KFGameType KF;
var config int ForceTo;
var config string ForceWay;

function PostBeginPlay() {
    super.PostBeginPlay();
    KF = KFGameType(Level.Game);
    if (KF == none) {
        Destroy();
        return;
    }
    SaveConfig();
}

function ModifyPlayer(Pawn Other) {
    super.ModifyPlayer(Other);
    if (KF != none) {
        ForceLevel();
    }
}

function Tick(float f) {
    if (KF != none) {
        ForceLevel();
    }
}

final function ForceLevel() {
    local Controller C;
    local int PerkLevel;

    for (C = Level.ControllerList; C != none; C = C.NextController) {
        if (C.bIsPlayer) {
            PerkLevel = KFPlayerReplicationInfo(C.PlayerReplicationInfo).ClientVeteranSkillLevel;

            if (PerkLevel < ForceTo && ForceWay == "Min") {
                KFPlayerReplicationInfo(C.PlayerReplicationInfo).ClientVeteranSkillLevel = ForceTo;
                continue;
            }
            if (PerkLevel > ForceTo && ForceWay == "Max") {
                KFPlayerReplicationInfo(C.PlayerReplicationInfo).ClientVeteranSkillLevel = ForceTo;
                continue;
            }
            if (PerkLevel != ForceTo && ForceWay == "Only") {
                KFPlayerReplicationInfo(C.PlayerReplicationInfo).ClientVeteranSkillLevel = ForceTo;
                continue;
            }
        }
    }
}

static function FillPlayInfo(PlayInfo PlayInfo) {
    super.FillPlayInfo(PlayInfo);

    PlayInfo.AddSetting(default.RulesGroup, "ForceTo", "Level", 0, 0, "text", "1;0:6");
    PlayInfo.AddSetting(default.RulesGroup, "ForceWay", "Way", 0, 0, "select"
    , "Min;at least"
    $ ";Max;at most"
    $ ";Only;exactly");
}

static function string GetDescriptionText(string s) {
    switch (s) {
        case "ForceTo":
            return "Choose desired level.";
        case "ForceWay":
            return "Choose desired method to force the level.";
    }
    return super.GetDescriptionText(s);
}

defaultproperties {
    GroupName="KF-ForcedLevel"
    FriendlyName="Forced Perk Level V2"
    Description="Modify perk levels to fit with the game."
    ForceTo=5
    ForceWay="Min"
}
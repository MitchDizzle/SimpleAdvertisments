#define PLUGIN_VERSION "1.0.1"
public Plugin myinfo = {
    name = "Simple Advertisments",
    author = "Mitch",
    description = "Spams chat",
    version = PLUGIN_VERSION,
    url = "mtch.tech"
};

ConVar cEnabled;
ConVar cTime;
Handle timerAdvertisments;
ArrayList alAdvertisments;
int ad;

public void OnPluginStart() {
	cEnabled = CreateConVar("sm_simpleads_enable", "1", "On/OFF");
	cTime = CreateConVar("sm_simpleads_interval", "60.0", "Seconds before displaying the next ad");
	cEnabled.AddChangeHook(ConVarChanged);
	cTime.AddChangeHook(ConVarChanged);
	AutoExecConfig(true, "SimpleAds");
	CreateConVar("sm_simpleads_version", PLUGIN_VERSION, "Simple Advertisments Version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_DONTRECORD);
}

public void OnMapStart() {
	parseColors();
	parseAds();
	createTimer();
}

public void OnMapEnd() {
	timerAdvertisments = null;
}

public void createTimer() {
	if(timerAdvertisments != null) {
		KillTimer(timerAdvertisments, false);
		timerAdvertisments = null;
	}
	if(cEnabled.BoolValue) {
		timerAdvertisments = CreateTimer(cTime.FloatValue, Timer_Advertise, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void ConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue) {
	createTimer();
}

public void parseAds() {
	ad = 0; //Current Displayed Advertisment
	if(alAdvertisments == null) {
		alAdvertisments = new ArrayList(ByteCountToCells(256));
	} else {
		alAdvertisments.Clear();
	}
	char tempPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, tempPath, sizeof(tempPath),"configs/advertisements.cfg");
	File hFile = OpenFile(tempPath, "r");
	char tempBuffer[256]; 
	while(ReadFileLine(hFile, tempBuffer, sizeof(tempBuffer))) {
		TrimString(tempBuffer);
		if(!StrEqual(tempBuffer,"",false) && StrContains(tempBuffer, "//", false) != 1) {
			colorFormat(tempBuffer, sizeof(tempBuffer));
			alAdvertisments.PushString(tempBuffer);
		}
	}
	delete hFile;
}

public Action Timer_Advertise(Handle timer) {
	char display[256];
	alAdvertisments.GetString(ad, display, sizeof(display));
	PrintToChatAll(display);
	ad++; //Increase the displayed ad and clamp it.
	if(ad >= alAdvertisments.Length) {
		ad = 0;
	}
}

char colorTag[17][12];
char colorUni[17][12];
public void parseColors() {
	for(int i = 1; i < 17; i++) {
		Format(colorTag[i], 12, "{%02X}", i);
		Format(colorUni[i], 12, "%c", i);
	}
}

public void colorFormat(char[] szMessage, int maxlength) {
	for(int i = 1; i < 17; i++) {
		ReplaceString(szMessage, maxlength, colorTag[i], colorUni[i]);
	}
}
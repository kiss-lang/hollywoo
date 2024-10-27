package hollywoo;

import haxe.Constraints.Function;
import haxe.Timer;
import kiss.AsyncEmbeddedScript2;
import kiss.Prelude;
import kiss.Stream;
import kiss.FuzzyMap;
import hollywoo.Scene;
import hollywoo.Director;
import hollywoo.StagePosition;
import haxe.Json;
import haxe.io.Path;
import uuid.Uuid;
import haxe.ds.Option;
import kiss_tools.JsonMap;
import kiss_tools.JsonArray;
import kiss_tools.JsonString;
import kiss_tools.JsonInt;
import kiss_tools.JsonFloat;
import kiss_tools.TimerWithPause;

using kiss.FuzzyMapTools;

enum DelayHandling {
    Auto;
    AutoWithSkip;
    Manual;
}

typedef VoiceLine = {
    trackKey:String,
    start:Float,
    end:Float,
    ?alts:Array<VoiceLine>
};

enum HistoryElement<Actor> {
    Sound(caption:String);
    Dialog(speakerName:String, type:SpeechType<Actor>, wryly:String, text:String);
    Super(text:String);
    // Scene change? To provide a horizontal divider or something? But what constitutes a scene change? Intercut would add too many.
    // I don't want to manually define scene changes though.
}

// (speakerName, character, wryly, args, text, skipCC, cc) -> cleanup function
typedef CustomDialogTypeHandler<Actor> = (String, Character<Actor>, String, Array<Dynamic>, String, Continuation, Continuation) -> (Void->Void);

enum CreditsLine {
    OneColumn(s:String);
    TwoColumn(left:String, right:String);
    ThreeColumn(left:String, center:String, right:String);
    Break;
}

enum PlayMode {
    NotSet;
    Read;
    Watch;
}

/**
 * Model/controller of a Hollywoo film, and main execution script
 */
@:build(kiss.Kiss.fossilBuild())
class Movie<Set, Actor, Sound, Song, Prop, VoiceTrack, Camera, LightSource:Jsonable<LightSource>> extends AsyncEmbeddedScript2 {
	// BEGIN KISS FOSSIL CODE
	// ["/Users/nat/repos/hollywoo/src/hollywoo/Movie.kiss"]
	public static function dynamicArray(?elements:Array<Dynamic>) return {
		elements;
	}
	public static function opposite(position:StagePosition) return {
		new StagePosition(-position.x, -position.y, -position.z);
	}
	public static var showCaptions(get,set):Bool;
	public static function get_showCaptions():Bool  return {
		if (Prelude.truthy({
			final _dsWDUwhajQ8C9PN1MXk47Y:Dynamic = sys.FileSystem.exists(".Movie.json");
			{
				if (Prelude.truthy(_dsWDUwhajQ8C9PN1MXk47Y)) {
					final _xeTAQKSTbwv2EBsR9cZ5Tx:Dynamic = !Prelude.truthy(sys.FileSystem.isDirectory(".Movie.json"));
					{
						_xeTAQKSTbwv2EBsR9cZ5Tx;
					};
				} else _dsWDUwhajQ8C9PN1MXk47Y;
			};
		})) {
			final content = sys.io.File.getContent(".Movie.json");final json:haxe.DynamicAccess<String> = haxe.Json.parse(content);
			{
				if (Prelude.truthy(json.exists("showCaptions"))) {
					var v:Bool = tink.Json.parse(json['showCaptions']);
					v;
				} else false;
			};
		} else {
			false;
		};
	}
	public static function set_showCaptions(v:Bool):Bool  return {
		if (Prelude.truthy({
			final _62RTEtyd3VieeLdXc84Mw6:Dynamic = sys.FileSystem.exists(".Movie.json");
			{
				if (Prelude.truthy(_62RTEtyd3VieeLdXc84Mw6)) {
					final _focZKcRRo1joXj3L6SBqVK:Dynamic = !Prelude.truthy(sys.FileSystem.isDirectory(".Movie.json"));
					{
						_focZKcRRo1joXj3L6SBqVK;
					};
				} else _62RTEtyd3VieeLdXc84Mw6;
			};
		})) {
			final content = sys.io.File.getContent(".Movie.json");final json:haxe.DynamicAccess<String> = haxe.Json.parse(content);
			{
				json["showCaptions"] = tink.Json.stringify(v);
				sys.io.File.saveContent(".Movie.json", haxe.Json.stringify(json));
				v;
			};
		} else {
			{
				final json:haxe.DynamicAccess<String> = haxe.Json.parse('{}');
				{
					json["showCaptions"] = tink.Json.stringify(v);
					sys.io.File.saveContent(".Movie.json", haxe.Json.stringify(json));
					v;
				};
			};
		};
	}
	public static var playMode(get,set):PlayMode;
	public static function get_playMode():PlayMode  return {
		if (Prelude.truthy({
			final _bmNu6fPHP6QLrcq2NAZwYJ:Dynamic = sys.FileSystem.exists(".Movie.json");
			{
				if (Prelude.truthy(_bmNu6fPHP6QLrcq2NAZwYJ)) {
					final _kUmz85kMPzxntkEvDi1AxG:Dynamic = !Prelude.truthy(sys.FileSystem.isDirectory(".Movie.json"));
					{
						_kUmz85kMPzxntkEvDi1AxG;
					};
				} else _bmNu6fPHP6QLrcq2NAZwYJ;
			};
		})) {
			final content = sys.io.File.getContent(".Movie.json");final json:haxe.DynamicAccess<String> = haxe.Json.parse(content);
			{
				if (Prelude.truthy(json.exists("playMode"))) {
					var v:PlayMode = tink.Json.parse(json['playMode']);
					v;
				} else NotSet;
			};
		} else {
			NotSet;
		};
	}
	public static function set_playMode(v:PlayMode):PlayMode  return {
		if (Prelude.truthy({
			final _jQfiC2fmZRautq9f5C2drG:Dynamic = sys.FileSystem.exists(".Movie.json");
			{
				if (Prelude.truthy(_jQfiC2fmZRautq9f5C2drG)) {
					final _oRyZakq5bHQwHwmo97EqxL:Dynamic = !Prelude.truthy(sys.FileSystem.isDirectory(".Movie.json"));
					{
						_oRyZakq5bHQwHwmo97EqxL;
					};
				} else _jQfiC2fmZRautq9f5C2drG;
			};
		})) {
			final content = sys.io.File.getContent(".Movie.json");final json:haxe.DynamicAccess<String> = haxe.Json.parse(content);
			{
				json["playMode"] = tink.Json.stringify(v);
				sys.io.File.saveContent(".Movie.json", haxe.Json.stringify(json));
				v;
			};
		} else {
			{
				final json:haxe.DynamicAccess<String> = haxe.Json.parse('{}');
				{
					json["playMode"] = tink.Json.stringify(v);
					sys.io.File.saveContent(".Movie.json", haxe.Json.stringify(json));
					v;
				};
			};
		};
	}
	public static final MAX_CAPTION_DURATION = 3;
	public var captionId:Int = 0;
	public final dialogHistory:Array<HistoryElement<Actor>> = new kiss.List([]);
	public static final MAX_DIALOG_HISTORY = 50;
	public var currentSong:String = "";
	public var currentSongVolumeMod:Float = 0;
	public var currentSongLooping:Bool = false;
	public final sets:FuzzyMap<Set> = new FuzzyMap<Set>();
	public final actors:FuzzyMap<Actor> = new FuzzyMap<Actor>();
	public final sounds:FuzzyMap<Sound> = new FuzzyMap<Sound>();
	public final soundDescriptions:FuzzyMap<String> = new FuzzyMap<String>();
	public final songs:FuzzyMap<Song> = new FuzzyMap<Song>();
	public final props:FuzzyMap<Prop> = new FuzzyMap<Prop>();
	public final voiceTracks:Map<String,VoiceTrack> = new Map();
	private final _customDialogTypeHandlers:Map<String,CustomDialogTypeHandler<Actor>> = new Map();
	public final voiceLines:FuzzyMap<FuzzyMap<VoiceLine>> = new FuzzyMap<FuzzyMap<VoiceLine>>();
	public final dirtyActors:Map<String,Bool> = new Map();
	public final dirtyProps:Map<String,Bool> = new Map();
	public final voiceTracksPerActor:Map<String,Int> = new Map();
	public var delayHandling:DelayHandling = AutoWithSkip;
	public var lastDelay:String = "";
	public var lastDelayLength:Float = 0;
	public final scenes:FuzzyMap<Scene<Set,Actor,Prop,Camera>> = new FuzzyMap<Scene<Set, Actor, Prop, Camera>>();
	public final shownScenes:Map<String,Bool> = new Map();
	public final shownProps:Map<String,Bool> = new Map();
	public final shownCharacters:Map<String,Bool> = new Map();
	public var isLoading = false;
	public var didLoading = false;
	public var scavenged = false;
	public function scavengeObjects(movie:Movie<Set,Actor,Sound,Song,Prop,VoiceTrack,Camera,LightSource>) return {
		scavenged = true;
		{
			var t = 0;var c = 0;
			{
				{
					for (key => actor in movie.actors) {
						t = Prelude.add(t, 1);
						if (Prelude.truthy(!Prelude.truthy(movie.dirtyActors.exists(key)))) {
							c = Prelude.add(c, 1);
							actors[key] = actor;
							movie.actors.remove(key);
						} else null;
					};
					null;
				};
				{
					for (key => prop in movie.props) {
						t = Prelude.add(t, 1);
						if (Prelude.truthy(!Prelude.truthy(movie.dirtyProps.exists(key)))) {
							c = Prelude.add(c, 1);
							props[key] = prop;
							movie.props.remove(key);
						} else null;
					};
					null;
				};
				{
					for (key => sound in movie.sounds) {
						t = Prelude.add(t, 1);
						c = Prelude.add(c, 1);
						soundDescriptions[key] = movie.soundDescriptions[key];
						sounds[key] = sound;
						movie.sounds.remove(key);
					};
					null;
				};
				{
					for (key => song in movie.songs) {
						t = Prelude.add(t, 1);
						c = Prelude.add(c, 1);
						songs[key] = song;
						movie.songs.remove(key);
					};
					null;
				};
				{
					for (key => voiceTrack in movie.voiceTracks) {
						t = Prelude.add(t, 1);
						c = Prelude.add(c, 1);
						voiceTracks[key] = voiceTrack;
						movie.voiceTracks.remove(key);
					};
					null;
				};
				{
					for (actor => vl in movie.voiceLines) {
						voiceLines[actor] = vl;
					};
					null;
				};
				Prelude.print((Prelude.add("scavenge reused ", Std.string({
					c;
				}), "/", Std.string({
					t;
				}), " objects") : String));
			};
		};
	}
	public function doCleanup():Void  {
		0;
	}
	public static function appearanceFlag(map:Map<String,Bool>, key:String):Appearance  return {
		if (Prelude.truthy(map[key])) ReAppearance else {
			map[key] = true;
			FirstAppearance;
		};
	}
	public var sceneKey:String = "";
	private function _currentScene() return {
		scenes[sceneKey];
	}
	public var intercutMap:FuzzyMap<String>;
	public var altIdx:Map<String,Int> = new Map();
	public function processIntercut(skipping:Bool, actorName:String, cc:Continuation):Void  {
		if (Prelude.truthy(intercutMap)) {
			{
				final _9QxgBhQp2jHeZEmsAF2Cq2 = try intercutMap[actorName] catch(e) {
					null;
				};
				{
					if (Prelude.truthy(_9QxgBhQp2jHeZEmsAF2Cq2)) switch _9QxgBhQp2jHeZEmsAF2Cq2 {
						case _ik1NtQPDSTx9RDbCpjFYVv if (Prelude.truthy(Prelude.isNull(_ik1NtQPDSTx9RDbCpjFYVv))):{
							{
								null;
							};
						};
						case sceneForActor:{
							{
								if (Prelude.truthy(!Prelude.truthy(Prelude.areEqual(sceneForActor, sceneKey)))) {
									setScene(skipping, sceneForActor, cc);
									return;
								} else null;
							};
						};
						default:{
							null;
						};
					} else null;
				};
			};
		} else null;
		cc();
	}
	private final _silentCustomDialogTypes:Map<String,Bool> = new Map();
	public static var playVoiceTracksForSilentDialog(get,set):Bool;
	public static function get_playVoiceTracksForSilentDialog():Bool  return {
		if (Prelude.truthy({
			final _gbNarqXEw6gqMmncRF7SY8:Dynamic = sys.FileSystem.exists(".Movie.json");
			{
				if (Prelude.truthy(_gbNarqXEw6gqMmncRF7SY8)) {
					final _8wBhuYN6ysUa5w9SjTKeFu:Dynamic = !Prelude.truthy(sys.FileSystem.isDirectory(".Movie.json"));
					{
						_8wBhuYN6ysUa5w9SjTKeFu;
					};
				} else _gbNarqXEw6gqMmncRF7SY8;
			};
		})) {
			final content = sys.io.File.getContent(".Movie.json");final json:haxe.DynamicAccess<String> = haxe.Json.parse(content);
			{
				if (Prelude.truthy(json.exists("playVoiceTracksForSilentDialog"))) {
					var v:Bool = tink.Json.parse(json['playVoiceTracksForSilentDialog']);
					v;
				} else false;
			};
		} else {
			false;
		};
	}
	public static function set_playVoiceTracksForSilentDialog(v:Bool):Bool  return {
		if (Prelude.truthy({
			final _8NvKXzpDFEcfBc4TPfcRSA:Dynamic = sys.FileSystem.exists(".Movie.json");
			{
				if (Prelude.truthy(_8NvKXzpDFEcfBc4TPfcRSA)) {
					final _cb1yWYbBi5FZdwqM5MT9fN:Dynamic = !Prelude.truthy(sys.FileSystem.isDirectory(".Movie.json"));
					{
						_cb1yWYbBi5FZdwqM5MT9fN;
					};
				} else _8NvKXzpDFEcfBc4TPfcRSA;
			};
		})) {
			final content = sys.io.File.getContent(".Movie.json");final json:haxe.DynamicAccess<String> = haxe.Json.parse(content);
			{
				json["playVoiceTracksForSilentDialog"] = tink.Json.stringify(v);
				sys.io.File.saveContent(".Movie.json", haxe.Json.stringify(json));
				v;
			};
		} else {
			{
				final json:haxe.DynamicAccess<String> = haxe.Json.parse('{}');
				{
					json["playVoiceTracksForSilentDialog"] = tink.Json.stringify(v);
					sys.io.File.saveContent(".Movie.json", haxe.Json.stringify(json));
					v;
				};
			};
		};
	}
	public function registerCustomDialogTypeHandler(key:String, handler:CustomDialogTypeHandler<Actor>, ?isSilent:Bool) return {
		_customDialogTypeHandlers.set(key, handler);
		if (Prelude.truthy(Prelude.truthy(isSilent))) {
			_silentCustomDialogTypes[key] = true;
		} else null;
	}
	private var _hideCustomDialog:()->Void = null;
	public static final DELAY_BETWEEN_VOICE_TRACKS = 0.1;
	public function showDialog(skipping:Bool, actorName, dialogType, wryly, text, cc, ?voCutoffPercent:Float):Void  {
		if (Prelude.truthy(_hideCustomDialog)) {
			_hideCustomDialog();
			_hideCustomDialog = null;
		} else null;
		dialogHistory.push(Dialog(actorName, dialogType, wryly, text));
		if (Prelude.truthy(skipping)) {
			cc();
			return;
		} else null;
		var cutoffTimer:kiss_tools.TimerWithPause.WrappedTimer = null;
		processIntercut(skipping, actorName, function() {
			runWithErrorChecking(function() {
				{
					{
						final inputDelayKey = inputKey();final isSilentType = Prelude.truthy({
							final _MPANpDnbcFWDgKEMBt6Lt = dialogType;
							{
								if (Prelude.truthy(_MPANpDnbcFWDgKEMBt6Lt)) switch _MPANpDnbcFWDgKEMBt6Lt {
									case _eycyMDBkZ4UBDiFRu7jYPb if (Prelude.truthy(Prelude.isNull(_eycyMDBkZ4UBDiFRu7jYPb))):{
										{
											null;
										};
									};
									case Custom(type, _, _):{
										{
											_silentCustomDialogTypes.exists(type);
										};
									};
									default:{
										null;
									};
								} else null;
							};
						});final cc = function() {
							{
								stopWaitForInput(inputDelayKey);
								if (Prelude.truthy(cutoffTimer)) {
									TimerWithPause.stop(cutoffTimer);
									director._hideDialog();
									cc();
								} else delay(skipping, DELAY_BETWEEN_VOICE_TRACKS, function() {
									{
										director._hideDialog();
										cc();
									};
								});
							};
						};var customCC = cc;var skipCC = cc;
						{
							function setVoCutoff(start, end) return {
								if (Prelude.truthy(voCutoffPercent)) {
									cutoffTimer = TimerWithPause.delay(function() {
										runWithErrorChecking(function() {
											{
												director._hideDialog();
												cc();
											};
										}, cc);
									}, Prelude.multiply(voCutoffPercent, Prelude.subtract(end, start)));
									function() {
										runWithErrorChecking(function() {
											{
												null;
											};
										}, null);
									};
								} else cc;
							};
							if (Prelude.truthy({
								final _5CwCwyEP62cAnDByrmk5wC:Dynamic = {
									final _6rhpVrJjDdMRTP9D43opsp:Dynamic = !Prelude.truthy(isSilentType);
									{
										if (Prelude.truthy(_6rhpVrJjDdMRTP9D43opsp)) _6rhpVrJjDdMRTP9D43opsp else {
											final _ebJLTkNETjWJBCH4SKRQZN:Dynamic = playVoiceTracksForSilentDialog;
											{
												_ebJLTkNETjWJBCH4SKRQZN;
											};
										};
									};
								};
								{
									if (Prelude.truthy(_5CwCwyEP62cAnDByrmk5wC)) {
										final _NHcs1GDgdozMu1x9Jp5Nq:Dynamic = actorName;
										{
											if (Prelude.truthy(_NHcs1GDgdozMu1x9Jp5Nq)) {
												final _mYHDMuVifQutTBtjhk2YWB:Dynamic = Prelude.lessThan(0, Lambda.count(voiceTracks));
												{
													_mYHDMuVifQutTBtjhk2YWB;
												};
											} else _NHcs1GDgdozMu1x9Jp5Nq;
										};
									} else _5CwCwyEP62cAnDByrmk5wC;
								};
							})) {
								switch {
										final voiceLineKey = if (Prelude.truthy(voiceLineMatches.exists(text))) voiceLineMatches.get(text).value else FuzzyMapTools.bestMatch(voiceLines[actorName], text, false);
										{
											if (Prelude.truthy(voiceLineKey)) {
												{
													voiceLineMatches.put(text, new JsonString(voiceLineKey));
												};
												voiceLines[actorName][voiceLineKey];
											} else null;
										};
									} {
									case _gpRZiM64DvkGPgU2TC3Lph if (Prelude.truthy(Prelude.isNull(_gpRZiM64DvkGPgU2TC3Lph))):{
										{ };
									};
									case { trackKey : trackKey, start : start, end : end, alts : alts }:{
										switch altIdx[(Prelude.add("", Std.string(actorName), " ", Std.string(text), "") : String)] {
											case _wksVSG1NWb334NriuTPEmu if (Prelude.truthy(Prelude.isNull(_wksVSG1NWb334NriuTPEmu))):{
												{
													altIdx[((Prelude.add("", Std.string(actorName), " ", Std.string(text), "") : String))] = 0;
													customCC = function() {
														{ };
													};
													director.playVoiceTrack(voiceTracks[trackKey], 1, start, end, setVoCutoff(start, end));
												};
											};
											case idx if (Prelude.truthy(Prelude.greaterEqual(idx, alts.length))):{
												altIdx[(Prelude.add("", Std.string(actorName), " ", Std.string(text), "") : String)] = 0;
												customCC = function() {
													{ };
												};
												setVoCutoff(start, end);
												director.playVoiceTrack(voiceTracks[trackKey], 1, start, end, setVoCutoff(start, end));
											};
											case idx:{
												{
													final alt = alts[idx];final start = alt.start;final end = alt.end;
													{
														altIdx[(Prelude.add("", Std.string(actorName), " ", Std.string(text), "") : String)] = Prelude.add(altIdx[(Prelude.add("", Std.string(actorName), " ", Std.string(text), "") : String)], 1);
														customCC = function() {
															{ };
														};
														setVoCutoff(start, end);
														director.playVoiceTrack(voiceTracks[trackKey], 1, start, end, setVoCutoff(start, end));
													};
												};
											};
										};
										skipCC = function() {
											{
												director.stopVoiceTrack(voiceTracks[trackKey]);
												cc();
											};
										};
									};
									case { trackKey : trackKey, start : start, end : end }:{
										director.playVoiceTrack(voiceTracks[trackKey], 1, start, end, setVoCutoff(start, end));
										skipCC = function() {
											{
												director.stopVoiceTrack(voiceTracks[trackKey]);
												cc();
											};
										};
									};
									default:{ };
								};
							} else null;
							switch dialogType {
								case _6Az7Z5YsS69aGPGjVD6sd2 if (Prelude.truthy(Prelude.isNull(_6Az7Z5YsS69aGPGjVD6sd2))):{
									{
										startWaitForInput(skipCC, inputDelayKey);
										director._showDialog(actorName, dialogType, wryly, text, skipCC);
									};
								};
								case Custom(type, character, args):{
									{
										final _bL386seLLZrH4CUD7cnA5X = _customDialogTypeHandlers[type];
										{
											if (Prelude.truthy(_bL386seLLZrH4CUD7cnA5X)) switch _bL386seLLZrH4CUD7cnA5X {
												case _fF4tiKn5eaaqYVoLNFciZH if (Prelude.truthy(Prelude.isNull(_fF4tiKn5eaaqYVoLNFciZH))):{
													{
														throw ((Prelude.add("No handler for custom dialog type ", Std.string(type), "") : String));
													};
												};
												case handler:{
													{
														final cleanupFunc = handler(actorName, character, wryly, args, text, skipCC, customCC);
														{
															_hideCustomDialog = cleanupFunc;
														};
													};
												};
												default:{
													throw (Prelude.add("No handler for custom dialog type ", Std.string(type), "") : String);
												};
											} else throw (Prelude.add("No handler for custom dialog type ", Std.string(type), "") : String);
										};
									};
								};
								default:{
									startWaitForInput(skipCC, inputDelayKey);
									director._showDialog(actorName, dialogType, wryly, text, skipCC);
								};
							};
						};
					};
				};
			}, cc);
		});
	}
	public var loadedObjects = 0;
	public var loadCalls = 0;
	private function _loadVoiceTrack(actorName, path:String, lineJson:String) return {
		loadCalls = Prelude.add(loadCalls, 1);
		{
			final actorNumVoiceTracks = {
				final _9Qjey2v25ssQznb3EvxfMy:Dynamic = voiceTracksPerActor[actorName];
				{
					if (Prelude.truthy(_9Qjey2v25ssQznb3EvxfMy)) _9Qjey2v25ssQznb3EvxfMy else {
						final _qBUPuUv3q16HU55uFNbL8Z:Dynamic = 0;
						{
							_qBUPuUv3q16HU55uFNbL8Z;
						};
					};
				};
			};final trackKey = (Prelude.add("", Std.string({
				actorName;
			}), "", Std.string({
				actorNumVoiceTracks;
			}), "") : String);
			{
				if (Prelude.truthy(voiceTracks.exists(trackKey))) {
					voiceTracksPerActor[actorName] = Prelude.add(1, actorNumVoiceTracks);
				} else if (Prelude.truthy(true)) {
					{
						final path = if (Prelude.truthy(StringTools.startsWith(path, assetDir))) path else assetPath("vo", path);
						{
							loadedObjects = Prelude.add(loadedObjects, 1);
							_addVoiceTrack(actorName, director.loadVoiceTrack(path), lineJson);
						};
					};
				} else null;
			};
		};
	}
	private function _addVoiceTrack(actorName, track:VoiceTrack, lineJson:String) return {
		{
			final _wNppq51zQcbGvrWjKenZEL = isLoading;
			{
				if (Prelude.truthy(_wNppq51zQcbGvrWjKenZEL)) _wNppq51zQcbGvrWjKenZEL else throw kiss.Prelude.runtimeInsertAssertionMessage("", "/Users/nat/repos/hollywoo/src/hollywoo/Movie.kiss:275:9: Assertion failed: \nFrom:[(assert isLoading)]", 4);
			};
		};
		{
			final actorNumVoiceTracks = {
				final _9evcLa6dESEoYXYuFzWfSm:Dynamic = voiceTracksPerActor[actorName];
				{
					if (Prelude.truthy(_9evcLa6dESEoYXYuFzWfSm)) _9evcLa6dESEoYXYuFzWfSm else {
						final _2bnFZ3W1m2wjHosWQJNCxr:Dynamic = 0;
						{
							_2bnFZ3W1m2wjHosWQJNCxr;
						};
					};
				};
			};final trackKey = (Prelude.add("", Std.string({
				actorName;
			}), "", Std.string({
				actorNumVoiceTracks;
			}), "") : String);final lines:haxe.DynamicAccess<Dynamic> = Json.parse(lineJson);
			{
				voiceTracksPerActor[actorName] = Prelude.add(1, actorNumVoiceTracks);
				voiceTracks[trackKey] = track;
				{
					for (key => line in lines.keyValueIterator()) {
						{
							final alts:Array<VoiceLine> = if (Prelude.truthy(line.alts)) [for (alt in (line.alts : Array<Dynamic>)) {
								{ start : alt.start, end : alt.end, trackKey : trackKey };
							}] else new kiss.List([]);
							{
								if (Prelude.truthy(!Prelude.truthy(voiceLines.existsExactly(actorName)))) {
									voiceLines[actorName] = new FuzzyMap<VoiceLine>();
								} else null;
								voiceLines[actorName][key] = { start : line.start, end : line.end, trackKey : trackKey, alts : alts };
							};
						};
					};
					null;
				};
			};
		};
	}
	private function _noVoiceTracks(actorName) return {
		{
			final _r3PkGYDPo3D845bm55ax6f = isLoading;
			{
				if (Prelude.truthy(_r3PkGYDPo3D845bm55ax6f)) _r3PkGYDPo3D845bm55ax6f else throw kiss.Prelude.runtimeInsertAssertionMessage("", "/Users/nat/repos/hollywoo/src/hollywoo/Movie.kiss:291:9: Assertion failed: \nFrom:[(assert isLoading)]", 4);
			};
		};
		voiceTracksPerActor[actorName] = 0;
		voiceLines[actorName] = new FuzzyMap<VoiceLine>();
	}
	private function _loadProp(name, path:String) return {
		loadCalls = Prelude.add(loadCalls, 1);
		if (Prelude.truthy(!Prelude.truthy(props.existsExactly(name)))) {
			{
				final path = if (Prelude.truthy(StringTools.startsWith(path, assetDir))) path else assetPath("images", path);
				{
					loadedObjects = Prelude.add(loadedObjects, 1);
					_addProp(name, director.loadProp(path));
				};
			};
		} else null;
	}
	private function _addProp(name, prop:Prop) return {
		{
			final _42azSX7yXThFGiwPLr1u7L = isLoading;
			{
				if (Prelude.truthy(_42azSX7yXThFGiwPLr1u7L)) _42azSX7yXThFGiwPLr1u7L else throw kiss.Prelude.runtimeInsertAssertionMessage("", "/Users/nat/repos/hollywoo/src/hollywoo/Movie.kiss:303:9: Assertion failed: \nFrom:[(assert isLoading)]", 4);
			};
		};
		props[name] = prop;
	}
	private function _loadSong(name, path:String) return {
		loadCalls = Prelude.add(loadCalls, 1);
		if (Prelude.truthy(!Prelude.truthy(songs.existsExactly(name)))) {
			{
				final path = if (Prelude.truthy(StringTools.startsWith(path, assetDir))) path else assetPath("music", path);
				{
					loadedObjects = Prelude.add(loadedObjects, 1);
					_addSong(name, director.loadSong(path));
				};
			};
		} else null;
	}
	private function _addSong(name, song:Song) return {
		{
			final _ogqG4XXkDnNETYmQ1igua3 = isLoading;
			{
				if (Prelude.truthy(_ogqG4XXkDnNETYmQ1igua3)) _ogqG4XXkDnNETYmQ1igua3 else throw kiss.Prelude.runtimeInsertAssertionMessage("", "/Users/nat/repos/hollywoo/src/hollywoo/Movie.kiss:314:9: Assertion failed: \nFrom:[(assert isLoading)]", 4);
			};
		};
		songs[name] = song;
	}
	private function _loadActor(name, path:String) return {
		loadCalls = Prelude.add(loadCalls, 1);
		if (Prelude.truthy(!Prelude.truthy(actors.existsExactly(name)))) {
			{
				final path = if (Prelude.truthy(StringTools.startsWith(path, assetDir))) path else assetPath("images", path);
				{
					loadedObjects = Prelude.add(loadedObjects, 1);
					_addActor(name, director.loadActor(path));
				};
			};
		} else null;
	}
	private function _addActor(name, actor:Actor) return {
		{
			final _qzqhsVoNmk6obUBBQYZ4eU = isLoading;
			{
				if (Prelude.truthy(_qzqhsVoNmk6obUBBQYZ4eU)) _qzqhsVoNmk6obUBBQYZ4eU else throw kiss.Prelude.runtimeInsertAssertionMessage("", "/Users/nat/repos/hollywoo/src/hollywoo/Movie.kiss:325:9: Assertion failed: \nFrom:[(assert isLoading)]", 4);
			};
		};
		actors[name] = actor;
	}
	private function _loadSet(name, path:String) return {
		loadCalls = Prelude.add(loadCalls, 1);
		if (Prelude.truthy(!Prelude.truthy(sets.existsExactly(name)))) {
			{
				final path = if (Prelude.truthy(StringTools.startsWith(path, assetDir))) path else assetPath("images", path);
				{
					loadedObjects = Prelude.add(loadedObjects, 1);
					_addSet(name, director.loadSet(path));
				};
			};
		} else null;
	}
	private function _addSet(name, set:Set) return {
		{
			final _x3v18r4yWRSZi39xWGJ8ux = isLoading;
			{
				if (Prelude.truthy(_x3v18r4yWRSZi39xWGJ8ux)) _x3v18r4yWRSZi39xWGJ8ux else throw kiss.Prelude.runtimeInsertAssertionMessage("", "/Users/nat/repos/hollywoo/src/hollywoo/Movie.kiss:336:9: Assertion failed: \nFrom:[(assert isLoading)]", 4);
			};
		};
		sets[name] = set;
	}
	private function _newSceneFromSet(name, setKey:String, time:SceneTime, perspective:ScenePerspective, camera:Camera) return {
		{
			final _bcTmXf4GrrPWrWPEJhuK6A = isLoading;
			{
				if (Prelude.truthy(_bcTmXf4GrrPWrWPEJhuK6A)) _bcTmXf4GrrPWrWPEJhuK6A else throw kiss.Prelude.runtimeInsertAssertionMessage("", "/Users/nat/repos/hollywoo/src/hollywoo/Movie.kiss:340:9: Assertion failed: \nFrom:[(assert isLoading)]", 4);
			};
		};
		scenes[name] = { set : director.cloneSet(sets[setKey]), characters : new FuzzyMap<Character<Actor>>(), actorAndPropPositionKeys : new FuzzyMap<String>(), propOrder : new kiss.List([]), props : new FuzzyMap<StageProp<Prop>>(), camera : camera, time : time, perspective : perspective };
	}
	private function _loadSound(name, path:String, description:String) return {
		loadCalls = Prelude.add(loadCalls, 1);
		if (Prelude.truthy(!Prelude.truthy(sounds.existsExactly(name)))) {
			{
				final path = if (Prelude.truthy(StringTools.startsWith(path, assetDir))) path else assetPath("sounds", path);
				{
					loadedObjects = Prelude.add(loadedObjects, 1);
					_addSound(name, director.loadSound(path), description);
				};
			};
		} else null;
	}
	private function _addSound(name, s:Sound, description:String) return {
		{
			final _bwGrZfUD8NqijbsTmnnJe = isLoading;
			{
				if (Prelude.truthy(_bwGrZfUD8NqijbsTmnnJe)) _bwGrZfUD8NqijbsTmnnJe else throw kiss.Prelude.runtimeInsertAssertionMessage("", "/Users/nat/repos/hollywoo/src/hollywoo/Movie.kiss:366:9: Assertion failed: \nFrom:[(assert isLoading)]", 4);
			};
		};
		sounds[name] = s;
		soundDescriptions[name] = description;
	}
	private function _ccForEachIterator<T>(iter:Iterator<T>, do_:(T,Continuation)->Void, finalCC:Continuation) return {
		{
			function doNext() {
				if (Prelude.truthy(iter.hasNext())) do_(iter.next(), doNext) else finalCC();
			};
			doNext();
		};
	}
	private function _ccForEach<T>(collection:Iterable<T>, do_:(T,Continuation)->Void, finalCC:Continuation) return {
		{
			final iter:Iterator<T> = collection.iterator();
			{
				_ccForEachIterator(iter, do_, finalCC);
			};
		};
	}
	private function _hideCurrentScene(cc:Continuation) return {
		if (Prelude.truthy(sceneKey)) {
			final currentScene = scenes[sceneKey];
			{
				director.hideLighting();
				director.hideSet(currentScene.set, currentScene.camera, function() {
					runWithErrorChecking(function() {
						{
							_ccForEach(currentScene.characters, function(c:Character<Actor>, cc:Continuation) return {
								director.hideCharacter(c, currentScene.camera, cc);
							}, function() {
								runWithErrorChecking(function() {
									{
										_ccForEach(currentScene.props, function(p:StageProp<Prop>, cc:Continuation) return {
											director.hideProp(p.prop, currentScene.camera, cc);
										}, cc);
									};
								}, cc);
							});
						};
					}, cc);
				});
			};
		} else cc();
	}
	private function _updateLighting() return {
		director.hideLighting();
		{
			final scene = _currentScene();final sceneKey = FuzzyMapTools.bestMatch(scenes, sceneKey);final sceneLightSources = lightSources.get(sceneKey).elements;final propLightSources:Array<LightSource> = Lambda.flatten([for (propKey => prop in scene.props) {
				if (Prelude.truthy(lightSources.exists(propKey))) [for (ls in lightSources.get(propKey).elements) {
					director.offsetLightSource(ls, prop.position);
				}] else new kiss.List([]);
			}]);final actorLightSources:Array<LightSource> = Lambda.flatten([for (actorKey => character in scene.characters) {
				if (Prelude.truthy(lightSources.exists(actorKey))) [for (ls in lightSources.get(actorKey).elements) {
					director.offsetLightSource(ls, character.stagePosition);
				}] else new kiss.List([]);
			}]);final allLightSources:Array<LightSource> = Lambda.flatten(new kiss.List([sceneLightSources, propLightSources, actorLightSources]));
			{
				director.showLighting(scene.time, allLightSources, scene.camera);
			};
		};
	}
	private function _showScene(scene:Scene<Set,Actor,Prop,Camera>, appearance:Appearance, camera:Camera, skipping:Bool, cc:Continuation) return {
		{
			final cc = function() {
				runWithErrorChecking(function() {
					{
						_updateLighting();
						cc();
					};
				}, cc);
			};
			{
				director.showSet(scene.set, scene.time, scene.perspective, appearance, camera, skipping, function() {
					runWithErrorChecking(function() {
						{
							_ccForEach({ iterator : function() return {
								scene.characters.keys();
							} }, function(key:String, cc:Continuation) return {
								director.showCharacter(scene.characters[key], appearanceFlag(shownCharacters, key), camera, cc);
							}, function() {
								runWithErrorChecking(function() {
									{
										_ccForEach(scene.propOrder, function(propKey:String, cc:Continuation) return {
											{
												final p = scene.props[propKey];
												{
													director.showProp(p.prop, p.position, ReAppearance, _currentScene().camera, cc);
												};
											};
										}, cc);
									};
								}, cc);
							});
						};
					}, cc);
				});
			};
		};
	}
	public var paused:Bool = false;
	public var onComplete:Continuation = null;
	public function pause() return {
		if (Prelude.truthy(!Prelude.truthy(paused))) {
			TimerWithPause.pause();
			paused = true;
			director.pause();
		} else null;
	}
	public function resume() return {
		if (Prelude.truthy(paused)) {
			paused = false;
			director.resume();
			TimerWithPause.resume();
		} else null;
	}
	public var promptedRecording = false;
	public function promptToRecord(cc:Continuation) return {
		if (Prelude.truthy(!Prelude.truthy(kiss_tools.OBSTools.obsIsRecording))) {
			director.chooseString("Start recording?", new kiss.List(["Yes", "No"]), function(choice) {
				switch choice {
					case _kdBUhvyTdUJipKJ1WiB439 if (Prelude.truthy(Prelude.isNull(_kdBUhvyTdUJipKJ1WiB439))):{
						{
							cc();
						};
					};
					case "Yes":{
						promptedRecording = true;
						director.prepareForRecording();
						kiss_tools.OBSTools.startObs();
						cc();
					};
					default:{
						cc();
					};
				};
			});
		} else null;
	}
	public function stopPromptedRecording() return {
		promptedRecording = {
			final _xeb17vd38PcTQWcSZRKyhB:Dynamic = promptedRecording;
			{
				if (Prelude.truthy(_xeb17vd38PcTQWcSZRKyhB)) {
					final _kF8frZ3e7Jvb2CvkLeHKjz:Dynamic = kiss_tools.OBSTools.obsIsRecording;
					{
						_kF8frZ3e7Jvb2CvkLeHKjz;
					};
				} else _xeb17vd38PcTQWcSZRKyhB;
			};
		};
		if (Prelude.truthy(promptedRecording)) {
			kiss_tools.OBSTools.stopObs();
			promptedRecording = false;
		} else null;
	}
	public final positionsInScene:Map<String,Array<String>> = new Map();
	public function resolvePosition(position:Dynamic, holder:String):StagePosition  return {
		{
			final _sHCv5zDq8t8NQ6UjNDqoQA:Dynamic = position;
			{
				switch [_sHCv5zDq8t8NQ6UjNDqoQA] {
					case [positionKey] if (Prelude.truthy({
						final _cwbUoYSGnrU5bY3aMKWLZQ:Dynamic = Std.isOfType(positionKey, String);
						{
							_cwbUoYSGnrU5bY3aMKWLZQ;
						};
					})):{
						{
							final positionKey:String = positionKey;
							{
								{
									final _tT6uihqaLLbWsrgTPsucwG = sceneKey;
									{
										if (Prelude.truthy(_tT6uihqaLLbWsrgTPsucwG)) _tT6uihqaLLbWsrgTPsucwG else throw kiss.Prelude.runtimeInsertAssertionMessage("resolvePosition() should be called in the context of a scene", "/Users/nat/repos/hollywoo/src/hollywoo/Movie.kiss:495:17: Assertion failed: \nFrom:[(assert sceneKey \"resolvePosition() should be called in the context of a scene\")]", 4);
									};
								};
								{
									final positionsInThisScene = positionsInScene[sceneKey];
									{
										if (Prelude.truthy(!Prelude.truthy(positionsInThisScene.contains(positionKey)))) {
											positionsInThisScene.push(positionKey);
										} else null;
									};
								};
								_currentScene().actorAndPropPositionKeys[holder] = positionKey;
								{
									final pos = stagePositions.get(positionKey);
									{
										{
											final _xsN2pXd8TPh9DB7QzND8bb = positionRelativity.get(positionKey).value;
											{
												if (Prelude.truthy(_xsN2pXd8TPh9DB7QzND8bb)) switch _xsN2pXd8TPh9DB7QzND8bb {
													case _tLsnx6CAdgZsVYdX5eygU7 if (Prelude.truthy(Prelude.isNull(_tLsnx6CAdgZsVYdX5eygU7))):{
														{
															pos;
														};
													};
													case relativeKey:{
														{
															final _uF8EusXmoXqdk9R6BeQEab = resolvePosition(relativeKey, null);
															{
																if (Prelude.truthy(_uF8EusXmoXqdk9R6BeQEab)) switch _uF8EusXmoXqdk9R6BeQEab {
																	case _39m1hgD9wMGeaRhDKUn9ec if (Prelude.truthy(Prelude.isNull(_39m1hgD9wMGeaRhDKUn9ec))):{
																		{
																			pos;
																		};
																	};
																	case anchorPos:{
																		new StagePosition({
																			anchorPos.x + pos.x;
																		}, {
																			anchorPos.y + pos.y;
																		}, {
																			anchorPos.z + pos.z;
																		});
																	};
																	default:{
																		pos;
																	};
																} else pos;
															};
														};
													};
													default:{
														pos;
													};
												} else pos;
											};
										};
									};
								};
							};
						};
					};
					case [position] if (Prelude.truthy({
						final _nN163BkR1PJ47g38XofeLV:Dynamic = Std.isOfType(position, StagePosition);
						{
							_nN163BkR1PJ47g38XofeLV;
						};
					})):{
						{
							final position:StagePosition = position;
							{
								position;
							};
						};
					};
					default:{
						throw (Prelude.add("Not a position or position key: ", Std.string(position), "") : String);
					};
				};
			};
		};
	}
	public var loopingSoundPlays:Map<String,Continuation> = new Map();
	public final assetPaths:FuzzyMap<FuzzyMap<String>> = new FuzzyMap();
	public var assetDir:String = "";
	public final loadedCredits:Array<Array<String>> = new kiss.List([]);
	public final loadedCreditSources:Array<String> = new kiss.List([]);
	private function _indexAssetPaths(assetDir:String) return {
		this.assetDir = assetDir;
		{
			final dirParts = assetDir.split("/");
			{
				{
					for (part in dirParts) {
						assetPaths[part] = new FuzzyMap();
					};
					null;
				};
			};
		};
		Prelude.walkDirectory("", assetDir, function(file) return {
			{
				final _kCNHkj6wDWX5AX34zwDov1 = file.split("/");
				{
					if (Prelude.truthy(_kCNHkj6wDWX5AX34zwDov1)) switch _kCNHkj6wDWX5AX34zwDov1 {
						case _eugHLmoGZi5MEndH6pyDNW if (Prelude.truthy(Prelude.isNull(_eugHLmoGZi5MEndH6pyDNW))):{
							{
								Prelude.print(((Prelude.add("Warning: asset ", Std.string(file), " cannot be indexed") : String)));
							};
						};
						case _aueS7cwVgSkBiXsh5Lc62 if (Prelude.greaterThan(_aueS7cwVgSkBiXsh5Lc62.length, 1)):{
							final dirs = _aueS7cwVgSkBiXsh5Lc62.slice(0, Prelude.subtract(_aueS7cwVgSkBiXsh5Lc62.length, 1));final basename = _aueS7cwVgSkBiXsh5Lc62[Prelude.subtract(_aueS7cwVgSkBiXsh5Lc62.length, 1)];
							{
								{
									final _a4zgdHeZcL7GFfFeCsX67G = Path.extension(file);
									{
										if (Prelude.truthy(_a4zgdHeZcL7GFfFeCsX67G)) switch _a4zgdHeZcL7GFfFeCsX67G {
											case _xq7kKeJexoaqyNxu3yZVNy if (Prelude.truthy(Prelude.isNull(_xq7kKeJexoaqyNxu3yZVNy))):{
												{
													Prelude.print(((Prelude.add("Warning: asset ", Std.string(file), " cannot be indexed") : String)));
												};
											};
											case ext:{
												{
													final _qPLoE3ZiQLn6FQtt2cV6uD = Path.withoutExtension(file);
													{
														if (Prelude.truthy(_qPLoE3ZiQLn6FQtt2cV6uD)) switch _qPLoE3ZiQLn6FQtt2cV6uD {
															case _sFXr2RygNB29FqGAKwMmuh if (Prelude.truthy(Prelude.isNull(_sFXr2RygNB29FqGAKwMmuh))):{
																{
																	Prelude.print(((Prelude.add("Warning: asset ", Std.string(file), " cannot be indexed") : String)));
																};
															};
															case noExt:{
																{
																	final _pjPwpatudevgJKkhFWsumM = new kiss.List(["Edited", "-edited"]);
																	{
																		if (Prelude.truthy(_pjPwpatudevgJKkhFWsumM)) switch _pjPwpatudevgJKkhFWsumM {
																			case _fTSQjwzM9x6oPkVN3WmjC if (Prelude.truthy(Prelude.isNull(_fTSQjwzM9x6oPkVN3WmjC))):{
																				{
																					Prelude.print(((Prelude.add("Warning: asset ", Std.string(file), " cannot be indexed") : String)));
																				};
																			};
																			case overrideEndings:{
																				{
																					final _tBHRunpadoHbBwKzH5a3qY = new kiss.List([(Prelude.add("", Std.string(ext), "") : String), "png", "wav", "ogg"]);
																					{
																						if (Prelude.truthy(_tBHRunpadoHbBwKzH5a3qY)) switch _tBHRunpadoHbBwKzH5a3qY {
																							case _gtokHCcqTx83h2HN3Mtc1k if (Prelude.truthy(Prelude.isNull(_gtokHCcqTx83h2HN3Mtc1k))):{
																								{
																									Prelude.print(((Prelude.add("Warning: asset ", Std.string(file), " cannot be indexed") : String)));
																								};
																							};
																							case overrideExtensions:{
																								{
																									final _xs89bntD2Q8QoSxg9eL46Z = file;
																									{
																										if (Prelude.truthy(_xs89bntD2Q8QoSxg9eL46Z)) switch _xs89bntD2Q8QoSxg9eL46Z {
																											case _ccaau2ZpsS4LssnguZ2pCP if (Prelude.truthy(Prelude.isNull(_ccaau2ZpsS4LssnguZ2pCP))):{
																												{
																													Prelude.print(((Prelude.add("Warning: asset ", Std.string(file), " cannot be indexed") : String)));
																												};
																											};
																											case overridePath:{
																												{
																													if (Prelude.truthy(Prelude.areEqual(ext, "tsv"))) {
																														{
																															final content = sys.io.File.getContent(file);final source = content.split("\t").shift();final sourceUrl = content.split("\t").pop();
																															{
																																switch source {
																																	case _aRKXqssX117Xe9kZmSxxfV if (Prelude.truthy(Prelude.isNull(_aRKXqssX117Xe9kZmSxxfV))):{
																																		{
																																			{
																																				if (Prelude.truthy(!Prelude.truthy(sys.FileSystem.exists(((Prelude.add("", Std.string({
																																					noExt;
																																				}), ".LICENSE.txt") : String)))))) {
																																					Prelude.print(((Prelude.add("Warning! License file may be required for redistributing ", Std.string(file), " from ", Std.string(sourceUrl), "") : String)));
																																				} else null;
																																			};
																																		};
																																	};
																																	case "pixabay.com":{
																																		null;
																																	};
																																	case "unsplash.com":{
																																		null;
																																	};
																																	case "openclipart.org":{
																																		null;
																																	};
																																	case "pixnio.com":{
																																		null;
																																	};
																																	default:{
																																		{
																																			if (Prelude.truthy(!Prelude.truthy(sys.FileSystem.exists((Prelude.add("", Std.string({
																																				noExt;
																																			}), ".LICENSE.txt") : String))))) {
																																				Prelude.print((Prelude.add("Warning! License file may be required for redistributing ", Std.string(file), " from ", Std.string(sourceUrl), "") : String));
																																			} else null;
																																		};
																																	};
																																};
																															};
																														};
																													} else if (Prelude.truthy(true)) {
																														{
																															for (_pFwjjQdNpNki9NRomhFa62 in (Prelude.intersect(overrideEndings, overrideExtensions) : Array<Array<Dynamic>>)) {
																																final _nFFpPbbzguruothc9Wjsx4 = _pFwjjQdNpNki9NRomhFa62;final ending = _nFFpPbbzguruothc9Wjsx4[0];final extension = _nFFpPbbzguruothc9Wjsx4[1];
																																{
																																	{
																																		final possibleOverride = (Prelude.add("", Std.string({
																																			noExt;
																																		}), "", Std.string({
																																			ending;
																																		}), ".", Std.string({
																																			extension;
																																		}), "") : String);
																																		{
																																			if (Prelude.truthy(sys.FileSystem.exists(possibleOverride))) {
																																				{
																																					Prelude.print((Prelude.add("", Std.string(file), " overridden by ", Std.string(possibleOverride), "") : String));
																																				};
																																				overridePath = possibleOverride;
																																				break;
																																			} else null;
																																		};
																																	};
																																};
																															};
																															null;
																														};
																													} else null;
																													{
																														for (dir in dirs) {
																															assetPaths[dir][basename] = overridePath;
																														};
																														null;
																													};
																												};
																											};
																											default:{
																												Prelude.print((Prelude.add("Warning: asset ", Std.string(file), " cannot be indexed") : String));
																											};
																										} else Prelude.print((Prelude.add("Warning: asset ", Std.string(file), " cannot be indexed") : String));
																									};
																								};
																							};
																							default:{
																								Prelude.print((Prelude.add("Warning: asset ", Std.string(file), " cannot be indexed") : String));
																							};
																						} else Prelude.print((Prelude.add("Warning: asset ", Std.string(file), " cannot be indexed") : String));
																					};
																				};
																			};
																			default:{
																				Prelude.print((Prelude.add("Warning: asset ", Std.string(file), " cannot be indexed") : String));
																			};
																		} else Prelude.print((Prelude.add("Warning: asset ", Std.string(file), " cannot be indexed") : String));
																	};
																};
															};
															default:{
																Prelude.print((Prelude.add("Warning: asset ", Std.string(file), " cannot be indexed") : String));
															};
														} else Prelude.print((Prelude.add("Warning: asset ", Std.string(file), " cannot be indexed") : String));
													};
												};
											};
											default:{
												Prelude.print((Prelude.add("Warning: asset ", Std.string(file), " cannot be indexed") : String));
											};
										} else Prelude.print((Prelude.add("Warning: asset ", Std.string(file), " cannot be indexed") : String));
									};
								};
							};
						};
						default:{
							Prelude.print((Prelude.add("Warning: asset ", Std.string(file), " cannot be indexed") : String));
						};
					} else Prelude.print((Prelude.add("Warning: asset ", Std.string(file), " cannot be indexed") : String));
				};
			};
		}, function(folderToFilter) return {
			{
				final _3S3rV8e3YTnJ3F9RFoKuZN = folderToFilter.split("/");
				{
					if (Prelude.truthy(_3S3rV8e3YTnJ3F9RFoKuZN)) switch _3S3rV8e3YTnJ3F9RFoKuZN {
						case _kFopb33cqJvr1kVC51A1Xn if (Prelude.truthy(Prelude.isNull(_kFopb33cqJvr1kVC51A1Xn))):{
							{
								throw "Assertion binding (folderToFilter.split \"/\") -> [::... dir] failed";
							};
						};
						case _5u8esoYqJJWqPUfxuUQzrf if (Prelude.greaterThan(_5u8esoYqJJWqPUfxuUQzrf.length, 1)):{
							final _ = _5u8esoYqJJWqPUfxuUQzrf.slice(0, Prelude.subtract(_5u8esoYqJJWqPUfxuUQzrf.length, 1));final dir = _5u8esoYqJJWqPUfxuUQzrf[Prelude.subtract(_5u8esoYqJJWqPUfxuUQzrf.length, 1)];
							{
								{
									if (Prelude.truthy(!Prelude.truthy(assetPaths.existsExactly(dir)))) {
										assetPaths[dir] = new FuzzyMap();
									} else null;
									false;
								};
							};
						};
						default:{
							throw "Assertion binding (folderToFilter.split \"/\") -> [::... dir] failed";
						};
					} else throw "Assertion binding (folderToFilter.split \"/\") -> [::... dir] failed";
				};
			};
		});
	}
	public function assetPath(directory, filename) return {
		{
			final dirMap = assetPaths[directory];final basename = FuzzyMapTools.bestMatch(dirMap, filename);final noExt = Path.withoutExtension(basename);final tsv = (Prelude.add("", Std.string({
				noExt;
			}), ".tsv") : String);
			{
				if (Prelude.truthy(dirMap.existsExactly(tsv))) {
					final tsvContent = sys.io.File.getContent(dirMap[tsv]);
					{
						loadedCredits.push(tsvContent.split("\t"));
						loadedCreditSources.push(tsv);
					};
				} else {
					Prelude.print((Prelude.add("Warning: no credit tsv file for ", Std.string({
						directory;
					}), "/", Std.string({
						filename;
					}), "") : String));
				};
				dirMap[basename];
			};
		};
	}
	public static function choosePlayMode(director:Director<Dynamic,Dynamic,Dynamic,Dynamic,Dynamic,Dynamic,Dynamic,Dynamic>, cc:()->Void) return {
		if (Prelude.truthy(director.movie)) {
			director.movie.paused = true;
		} else null;
		director.chooseString("Choose a Play Mode\n\nThe Play Mode setting determines how the story will flow forward.\n\nRead mode lets you go at your own pace, stopping after most dialogue until you choose to continue.\n\nWatch mode proceeds automatically like a cutscene or a movie.\n\nYou can still skip dialogue or speed up animations in either mode.\n\nYou can change your decision any time in the Options menu.\n\n", new kiss.List(["Read Mode", "Watch Mode (Recommended)"]), function(mode) {
			{
				switch mode {
					case _5XcdqUgDDwFrURjgMKoBcH if (Prelude.truthy(Prelude.isNull(_5XcdqUgDDwFrURjgMKoBcH))):{
						{
							throw kiss.Prelude.runtimeInsertAssertionMessage("case should never match pattern otherwise", "/Users/nat/repos/hollywoo/src/hollywoo/Movie.kiss:596:21: Assertion failed: \nFrom:[(never otherwise)]", 4);
						};
					};
					case "Read Mode":{
						Movie.playMode = Read;
					};
					case "Watch Mode (Recommended)":{
						Movie.playMode = Watch;
					};
					default:{
						throw kiss.Prelude.runtimeInsertAssertionMessage("case should never match pattern otherwise", "/Users/nat/repos/hollywoo/src/hollywoo/Movie.kiss:596:21: Assertion failed: \nFrom:[(never otherwise)]", 4);
					};
				};
				Prelude.print(Movie.playMode, "Movie.playMode");
				if (Prelude.truthy(director.movie)) {
					director.movie.delayHandling = switch hollywoo.Movie.playMode {
						case _qBbtEqM1pUs3Ywy53ErWns if (Prelude.truthy(Prelude.isNull(_qBbtEqM1pUs3Ywy53ErWns))):{
							{
								throw kiss.Prelude.runtimeInsertAssertionMessage("case should never match pattern otherwise", "/Users/nat/repos/hollywoo/src/hollywoo/Movie.kiss:604:29: Assertion failed: \nFrom:[(never otherwise)]", 4);
							};
						};
						case Read:{
							Manual;
						};
						case Watch:{
							AutoWithSkip;
						};
						default:{
							throw kiss.Prelude.runtimeInsertAssertionMessage("case should never match pattern otherwise", "/Users/nat/repos/hollywoo/src/hollywoo/Movie.kiss:604:29: Assertion failed: \nFrom:[(never otherwise)]", 4);
						};
					};
					director.movie.paused = false;
				} else null;
				cc();
			};
		});
	}
	public final stagePositions:JsonMap<StagePosition>;
	public final lightSources:JsonMap<JsonArray<LightSource>>;
	public final delayLengths:JsonMap<JsonFloat>;
	public final voiceLineMatches:JsonStringMap;
	public final miscFloats:JsonMap<JsonFloat>;
	public final miscFloatChangeEvents:Map<String,(Float)->Void>;
	public final miscInts:JsonMap<JsonInt>;
	public final miscIntChangeEvents:Map<String,(Int)->Void>;
	public final positionRelativity:JsonStringMap;
	public final sceneMusic:Map<String,String>;
	public final sceneMusicVolume:Map<String,Float>;
	public var playingSceneMusic:String;
	public var lastCommand:(Continuation)->Void;
	public final director:Director<Set,Actor,Sound,Song,Prop,VoiceTrack,Camera,LightSource>;
	public var doingSomething = false;
	public final CANCEL_COMMAND = "CANCEL CHOICE";
	public function withCancel(choices) return {
		new kiss.List([CANCEL_COMMAND]).concat(choices);
	}
	public function new(director:Director<Set,Actor,Sound,Song,Prop,VoiceTrack,Camera,LightSource>, lightSourceJsonFile:String, defaultLightSource:LightSource, stagePositionsJson:String, delayLengthsJson:String, voiceLineMatchesJson:String, miscFloatJson:String, miscIntJson:String, positionRelativityJson:String) {
		stagePositions = new JsonMap(stagePositionsJson, new StagePosition(0, 0, 0));
		lightSources = new JsonMap(lightSourceJsonFile, new JsonArray(new kiss.List([]), defaultLightSource));
		delayLengths = new JsonMap(delayLengthsJson, new JsonFloat(0.5));
		voiceLineMatches = new JsonMap(voiceLineMatchesJson, new JsonString(""));
		miscFloats = new JsonMap(miscFloatJson, new JsonFloat(0));
		miscFloatChangeEvents = new Map();
		miscInts = new JsonMap(miscIntJson, new JsonInt(0));
		miscIntChangeEvents = new Map();
		positionRelativity = new JsonMap(positionRelativityJson, new JsonString(""));
		sceneMusic = new Map();
		sceneMusicVolume = new Map();
		playingSceneMusic = null;
		lastCommand = function(cc) {
			cc();
		};
		this.director = director;
		super();
		director.movie = this;
		onSkipEnd = function() {
			{
				{
					for (play in loopingSoundPlays) {
						play();
					};
					null;
				};
				if (Prelude.truthy(currentSong)) {
					playSong(false, currentSong, function() {
						{ };
					}, currentSongVolumeMod, currentSongLooping, false);
				} else null;
			};
		};
		{ };
		{
			final shortcutHandler = director.shortcutHandler();final redefineNormalShortcuts = function() return {
				{
					shortcutHandler.registerItem("{escape} Pause the movie", function(cc) return {
						if (Prelude.truthy(!Prelude.truthy(doingSomething))) {
							doingSomething = true;
							director.showPauseMenu(cc);
						} else null;
					}, true);
					shortcutHandler.registerItem("{tab} show dialog history", function(cc) return {
						if (Prelude.truthy(!Prelude.truthy(doingSomething))) {
							doingSomething = true;
							director.showDialogHistory(if (Prelude.truthy(Prelude.greaterThan(dialogHistory.length, MAX_DIALOG_HISTORY))) dialogHistory.slice(Prelude.subtract(dialogHistory.length, MAX_DIALOG_HISTORY)) else dialogHistory, cc);
						} else null;
					}, true);
				};
			};final cc = function() return {
				{
					doingSomething = false;
					redefineNormalShortcuts();
					resume();
				};
			};
			{
				shortcutHandler.onSelectItem = function(process) return {
					{
						pause();
						shortcutHandler.start();
						process(cc);
					};
				};
				shortcutHandler.onBadKey = function(_, _) return {
					if (Prelude.truthy(shortcutHandler.currentMap)) {
						shortcutHandler.start();
					} else null;
				};
				redefineNormalShortcuts();
				{
					shortcutHandler.registerItem("[.] repeat last command", function(cc) return {
						if (Prelude.truthy(!Prelude.truthy(doingSomething))) {
							doingSomething = true;
							lastCommand(cc);
						} else null;
					});
					function redefineLastDelay(cc) return {
						if (Prelude.truthy(doingSomething)) {
							return;
						} else null;
						doingSomething = true;
						lastCommand = redefineLastDelay;
						if (Prelude.truthy(lastDelay)) director.enterString((Prelude.add("Redefine ", Std.string(lastDelay), " from ", Std.string(lastDelayLength), " sec?") : String), function(lengthStr) return {
							{
								final length = Std.parseFloat(lengthStr);
								{
									if (Prelude.truthy(Math.isNaN(length))) Prelude.print((Prelude.add("Failed to parse ", Std.string({
										lengthStr;
									}), ". leaving value the same") : String)) else delayLengths.put(lastDelay, new JsonFloat(length));
									cc();
								};
							};
						}) else {
							Prelude.print("no delay to redefine");
							cc();
						};
					};
					shortcutHandler.registerItem("[d]efine [d]elay", redefineLastDelay);
					{ };
					{ };
					shortcutHandler.registerItem("[d]efine [m]isc [i]nt", function(cc) return {
						if (Prelude.truthy(!Prelude.truthy(doingSomething))) {
							doingSomething = true;
							director.chooseString("Which misc int?", withCancel([for (elem in miscInts.keys()) {
								elem;
							}]), function(key) return {
								if (Prelude.truthy(Prelude.areEqual(key, CANCEL_COMMAND))) cc() else {
									function defineMiscInt(cc) return {
										director.enterString((Prelude.add("Redefine ", Std.string(key), " from ", Std.string({
											miscInts.get(key).value;
										}), "?") : String), function(valStr) return {
											{
												final v = Std.parseInt(valStr);
												{
													if (Prelude.truthy(Prelude.areEqual(v, null))) Prelude.print((Prelude.add("Failed to parse ", Std.string({
														valStr;
													}), ". leaving value the same") : String)) else {
														miscInts.put(key, new JsonInt(v));
														{
															final _xx8JrKc3rZEwj68UtNYrX7 = miscIntChangeEvents[key];
															{
																if (Prelude.truthy(_xx8JrKc3rZEwj68UtNYrX7)) switch _xx8JrKc3rZEwj68UtNYrX7 {
																	case _61bc6y3SZ26aS2PbRqBukV if (Prelude.truthy(Prelude.isNull(_61bc6y3SZ26aS2PbRqBukV))):{
																		{
																			null;
																		};
																	};
																	case onChange:{
																		onChange(v);
																	};
																	default:{
																		null;
																	};
																} else null;
															};
														};
													};
													cc();
												};
											};
										});
									};
									lastCommand = defineMiscInt;
									defineMiscInt(cc);
								};
							});
						} else null;
					});
					shortcutHandler.registerItem("[d]efine [m]isc [f]loat", function(cc) return {
						if (Prelude.truthy(!Prelude.truthy(doingSomething))) {
							doingSomething = true;
							director.chooseString("Which misc float?", withCancel([for (elem in miscFloats.keys()) {
								elem;
							}]), function(key) return {
								if (Prelude.truthy(Prelude.areEqual(key, CANCEL_COMMAND))) cc() else {
									function defineMiscFloat(cc) return {
										director.enterString((Prelude.add("Redefine ", Std.string(key), " from ", Std.string({
											miscFloats.get(key).value;
										}), "?") : String), function(valStr) return {
											{
												final v = Std.parseFloat(valStr);
												{
													if (Prelude.truthy(Math.isNaN(v))) Prelude.print((Prelude.add("Failed to parse ", Std.string({
														valStr;
													}), ". leaving value the same") : String)) else {
														miscFloats.put(key, new JsonFloat(v));
														{
															final _xyRNS6cDMF6u2h7tgeb4kw = miscFloatChangeEvents[key];
															{
																if (Prelude.truthy(_xyRNS6cDMF6u2h7tgeb4kw)) switch _xyRNS6cDMF6u2h7tgeb4kw {
																	case _9KxGzTJRreWcVeRX8V3CDe if (Prelude.truthy(Prelude.isNull(_9KxGzTJRreWcVeRX8V3CDe))):{
																		{
																			null;
																		};
																	};
																	case onChange:{
																		onChange(v);
																	};
																	default:{
																		null;
																	};
																} else null;
															};
														};
													};
													cc();
												};
											};
										});
									};
									lastCommand = defineMiscFloat;
									defineMiscFloat(cc);
								};
							});
						} else null;
					});
					shortcutHandler.registerItem("[d]efine [p]osition", function(cc) return {
						if (Prelude.truthy(!Prelude.truthy(doingSomething))) {
							doingSomething = true;
							director.chooseString("Which position?", withCancel(positionsInScene[sceneKey]), function(positionKey) return {
								if (Prelude.truthy(Prelude.areEqual(positionKey, CANCEL_COMMAND))) cc() else {
									function defineStagePosition(cc) return {
										director.defineStagePosition(_currentScene().camera, function(position:StagePosition) return {
											{
												stagePositions.put(positionKey, {
													final _jMH4FbwWAkVYbRFCuABweP = positionRelativity.get(positionKey).value;
													{
														if (Prelude.truthy(_jMH4FbwWAkVYbRFCuABweP)) switch _jMH4FbwWAkVYbRFCuABweP {
															case _juiuXuASbSxpjkjjHqaxGV if (Prelude.truthy(Prelude.isNull(_juiuXuASbSxpjkjjHqaxGV))):{
																{
																	position;
																};
															};
															case relativeKey:{
																{
																	final _o4uhHC1bxZXZ5CLxEmJHy2 = resolvePosition(relativeKey, null);
																	{
																		if (Prelude.truthy(_o4uhHC1bxZXZ5CLxEmJHy2)) switch _o4uhHC1bxZXZ5CLxEmJHy2 {
																			case _nRFggwD49LeKR2geD4pxmm if (Prelude.truthy(Prelude.isNull(_nRFggwD49LeKR2geD4pxmm))):{
																				{
																					position;
																				};
																			};
																			case anchorPos:{
																				new StagePosition(Prelude.subtract(position.x, anchorPos.x), Prelude.subtract(position.y, anchorPos.y), Prelude.subtract(position.z, anchorPos.z));
																			};
																			default:{
																				position;
																			};
																		} else position;
																	};
																};
															};
															default:{
																position;
															};
														} else position;
													};
												});
												{
													final scene = _currentScene();final characterIterator = scene.characters.keys();final propOrder = scene.propOrder.copy();
													{
														{
															function nextProp() return {
																{
																	final _jbEynFSuMyAXEAkPtBuf6F = propOrder.shift();
																	{
																		if (Prelude.truthy(_jbEynFSuMyAXEAkPtBuf6F)) switch _jbEynFSuMyAXEAkPtBuf6F {
																			case _KA2dV5oEkWfAhAk4YTUjn if (Prelude.truthy(Prelude.isNull(_KA2dV5oEkWfAhAk4YTUjn))):{
																				{
																					{
																						_updateLighting();
																						cc();
																					};
																				};
																			};
																			case key:{
																				{
																					final _grQJEj23v3qf1LSrBZdiQn = scene.props[key];
																					{
																						if (Prelude.truthy(_grQJEj23v3qf1LSrBZdiQn)) switch _grQJEj23v3qf1LSrBZdiQn {
																							case _vx4x7T76V2YTwxY89RtJW if (Prelude.truthy(Prelude.isNull(_vx4x7T76V2YTwxY89RtJW))):{
																								{
																									{
																										_updateLighting();
																										cc();
																									};
																								};
																							};
																							case prop:{
																								director.hideProp(prop.prop, scene.camera, function() {
																									runWithErrorChecking(function() {
																										{
																											if (Prelude.truthy(scene.actorAndPropPositionKeys.exists(key))) {
																												prop.position = resolvePosition(scene.actorAndPropPositionKeys[key], null);
																											} else null;
																											director.showProp(prop.prop, prop.position, ReAppearance, scene.camera, nextProp);
																										};
																									}, nextProp);
																								});
																							};
																							default:{
																								{
																									_updateLighting();
																									cc();
																								};
																							};
																						} else {
																							_updateLighting();
																							cc();
																						};
																					};
																				};
																			};
																			default:{
																				{
																					_updateLighting();
																					cc();
																				};
																			};
																		} else {
																			_updateLighting();
																			cc();
																		};
																	};
																};
															};
															function nextCharacter() return {
																if (Prelude.truthy(characterIterator.hasNext())) {
																	final key = characterIterator.next();final character = scene.characters[key];
																	{
																		director.hideCharacter(character, scene.camera, function() {
																			runWithErrorChecking(function() {
																				{
																					if (Prelude.truthy(scene.actorAndPropPositionKeys.exists(key))) {
																						character.stagePosition = resolvePosition(scene.actorAndPropPositionKeys[key], null);
																					} else null;
																					director.showCharacter(character, ReAppearance, scene.camera, nextCharacter);
																				};
																			}, nextCharacter);
																		});
																	};
																} else nextProp();
															};
															nextCharacter();
														};
													};
												};
											};
										}, resolvePosition(positionKey, null));
									};
									lastCommand = defineStagePosition;
									defineStagePosition(cc);
								};
							});
						} else null;
					});
					shortcutHandler.registerItem("[d]efine [r]elativity of position", function(cc) return {
						if (Prelude.truthy(!Prelude.truthy(doingSomething))) {
							doingSomething = true;
							director.chooseString("Which position?", withCancel(positionsInScene[sceneKey]), function(positionKey) return {
								if (Prelude.truthy(Prelude.areEqual(positionKey, CANCEL_COMMAND))) cc() else {
									function defineRelativity(cc) return {
										director.chooseString("Make relative to which position?", {
											final keys = positionsInScene[sceneKey].copy();
											{
												keys.remove(positionKey);
												withCancel(keys);
											};
										}, function(relativeKey) return {
											if (Prelude.truthy(Prelude.areEqual(relativeKey, CANCEL_COMMAND))) cc() else {
												final pos = resolvePosition(positionKey, null);final anchorPos = resolvePosition(relativeKey, null);
												{
													positionRelativity.put(positionKey, new JsonString(relativeKey));
													stagePositions.put(positionKey, new StagePosition(Prelude.subtract(pos.x, anchorPos.x), Prelude.subtract(pos.y, anchorPos.y), Prelude.subtract(pos.z, anchorPos.z)));
												};
											};
										});
									};
									lastCommand = defineRelativity;
									defineRelativity(cc);
								};
							});
						} else null;
					});
					function defineLightSource(cc) return {
						if (Prelude.truthy(doingSomething)) {
							return;
						} else null;
						doingSomething = true;
						lastCommand = defineLightSource;
						director.defineLightSource(function(source:LightSource) return {
							{
								{
									final arr = lightSources.get(sceneKey);
									{
										arr.elements.push(source);
										lightSources.put(sceneKey, arr);
										_updateLighting();
										cc();
									};
								};
							};
						});
					};
					shortcutHandler.registerItem("[d]efine [l]ight source", defineLightSource);
					function removeLightSource(cc) return {
						if (Prelude.truthy(doingSomething)) {
							return;
						} else null;
						doingSomething = true;
						lastCommand = removeLightSource;
						{
							final arr = lightSources.get(sceneKey);final stringArr = [for (ls in arr) {
								ls.stringify();
							}];final stringMap = [for (_4urq8FLVcyEo9LTQHcVQHp in (Prelude.zipThrow(stringArr, arr) : Array<Array<Dynamic>>)) {
								final _vDa9HJsyNqCHTY7PLUuJKJ = _4urq8FLVcyEo9LTQHcVQHp;final key = _vDa9HJsyNqCHTY7PLUuJKJ[0];final ls = _vDa9HJsyNqCHTY7PLUuJKJ[1];
								{
									key => ls;
								};
							}];
							{
								director.chooseString("Remove which light source?", withCancel(stringArr), function(choice) return {
									if (Prelude.truthy(Prelude.areEqual(choice, CANCEL_COMMAND))) cc() else {
										final ls = stringMap[choice];
										{
											arr.elements.remove(ls);
											lightSources.put(sceneKey, arr);
											_updateLighting();
											cc();
										};
									};
								});
							};
						};
					};
					shortcutHandler.registerItem("[r]emove [l]ight source", removeLightSource);
					function connectLightSourceToProp(cc) return {
						if (Prelude.truthy(doingSomething)) {
							return;
						} else null;
						doingSomething = true;
						lastCommand = connectLightSourceToProp;
						{
							final arr = lightSources.get(sceneKey);final stringArr = [for (ls in arr) {
								ls.stringify();
							}];final stringMap = [for (_jJUVpsLz3yZ4JtpDVmwyTy in (Prelude.zipThrow(stringArr, arr) : Array<Array<Dynamic>>)) {
								final _7ShSGvXfiX7dzjrfkjjnAU = _jJUVpsLz3yZ4JtpDVmwyTy;final key = _7ShSGvXfiX7dzjrfkjjnAU[0];final ls = _7ShSGvXfiX7dzjrfkjjnAU[1];
								{
									key => ls;
								};
							}];
							{
								director.chooseString("Connect which light source?", withCancel(stringArr), function(choice) return {
									if (Prelude.truthy(Prelude.areEqual(choice, CANCEL_COMMAND))) cc() else {
										final ls = stringMap[choice];final propsArr = [for (elem in _currentScene().props.keys()) {
											elem;
										}];
										{
											director.chooseString("Connect to which prop?", withCancel(propsArr), function(propChoice) return {
												if (Prelude.truthy(Prelude.areEqual(propChoice, CANCEL_COMMAND))) cc() else {
													final prop = _currentScene().props[propChoice];final relativeLS = director.offsetLightSource(ls, opposite(prop.position));final propLightSources = lightSources.get(propChoice);
													{
														arr.elements.remove(ls);
														lightSources.put(sceneKey, arr);
														propLightSources.elements.push(relativeLS);
														lightSources.put(propChoice, propLightSources);
														_updateLighting();
														cc();
													};
												};
											});
										};
									};
								});
							};
						};
					};
					shortcutHandler.registerItem("[c]onnect [l]ight source to [p]rop", connectLightSourceToProp);
					function connectLightSourceToActor(cc) return {
						if (Prelude.truthy(doingSomething)) {
							return;
						} else null;
						doingSomething = true;
						lastCommand = connectLightSourceToActor;
						{
							final arr = lightSources.get(sceneKey);final stringArr = [for (ls in arr) {
								ls.stringify();
							}];final stringMap = [for (_kytXcxUyCkukSfmiiunbXs in (Prelude.zipThrow(stringArr, arr) : Array<Array<Dynamic>>)) {
								final _9uHg364a1KJnum1ipRiPB = _kytXcxUyCkukSfmiiunbXs;final key = _9uHg364a1KJnum1ipRiPB[0];final ls = _9uHg364a1KJnum1ipRiPB[1];
								{
									key => ls;
								};
							}];
							{
								director.chooseString("Connect which light source?", withCancel(stringArr), function(choice) return {
									if (Prelude.truthy(Prelude.areEqual(choice, CANCEL_COMMAND))) cc() else {
										final ls = stringMap[choice];final actorArr = [for (elem in _currentScene().characters.keys()) {
											elem;
										}];
										{
											director.chooseString("Connect to which actor?", withCancel(actorArr), function(actorChoice) return {
												if (Prelude.truthy(Prelude.areEqual(actorChoice, CANCEL_COMMAND))) cc() else {
													final character = _currentScene().characters[actorChoice];final relativeLS = director.offsetLightSource(ls, opposite(character.stagePosition));final actorLightSources = lightSources.get(actorChoice);
													{
														arr.elements.remove(ls);
														lightSources.put(sceneKey, arr);
														actorLightSources.elements.push(relativeLS);
														lightSources.put(actorChoice, actorLightSources);
														_updateLighting();
														cc();
													};
												};
											});
										};
									};
								});
							};
						};
					};
					shortcutHandler.registerItem("[c]onnect [l]ight source to [a]ctor", connectLightSourceToActor);
				};
			};
		};
	}
	private function _strobe(skipping:Bool, prop:Bool, actorOrPropKey:String, strobeSec:Float, times:Int, ?cc:Continuation):Void  {
		if (Prelude.truthy(skipping)) {
			if (Prelude.truthy(cc)) {
				cc();
			} else null;
			return;
		} else null;
		{
			var propOrCharacter:Dynamic = if (Prelude.truthy(prop)) _currentScene().props[actorOrPropKey] else _currentScene().characters[actorOrPropKey];final appearance = ReAppearance;final camera = _currentScene().camera;var shown = true;final show:Function = if (Prelude.truthy(prop)) {
				final _prop = propOrCharacter.prop;final _position = propOrCharacter.position;
				{
					propOrCharacter = _prop;
					director.showProp.bind(_, _position);
				};
			} else director.showCharacter;final hide:Function = if (Prelude.truthy(prop)) director.hideProp else director.hideCharacter;
			{
				TimerWithPause.interval(function() {
					if (Prelude.truthy(shown)) {
						hide(propOrCharacter, camera, function() {
							{ };
						});
						shown = false;
					} else {
						show(propOrCharacter, appearance, camera, function() {
							{ };
						});
						shown = true;
					};
				}, strobeSec, Prelude.multiply(times, 2));
				if (Prelude.truthy(cc)) {
					TimerWithPause.delay(cc, Prelude.multiply(strobeSec, 2, Prelude.add(1, times)));
				} else null;
			};
		};
	}
	public function handleCaption(skipping:Bool, name:String):Void  {
		if (Prelude.truthy(showCaptions)) {
			{
				final _tiShUoNWDaEDPaagDyhk8k = soundDescriptions[name];
				{
					if (Prelude.truthy(_tiShUoNWDaEDPaagDyhk8k)) switch _tiShUoNWDaEDPaagDyhk8k {
						case _x4BvndRPK9UfhVZcLABKi8 if (Prelude.truthy(Prelude.isNull(_x4BvndRPK9UfhVZcLABKi8))):{
							{
								null;
							};
						};
						case desc:{
							{
								final _gRnu9RSj6PFbvBm5ptbA6F = captionId++;
								{
									if (Prelude.truthy(_gRnu9RSj6PFbvBm5ptbA6F)) switch _gRnu9RSj6PFbvBm5ptbA6F {
										case _rwa7vdKb3y6uuLbqTzWdan if (Prelude.truthy(Prelude.isNull(_rwa7vdKb3y6uuLbqTzWdan))):{
											{
												null;
											};
										};
										case id:{
											{
												final _aNfKn2e8x5SdeguPK5zBJm = sounds[name];
												{
													if (Prelude.truthy(_aNfKn2e8x5SdeguPK5zBJm)) switch _aNfKn2e8x5SdeguPK5zBJm {
														case _jvFsVeTHDcxrAspLrEqUHo if (Prelude.truthy(Prelude.isNull(_jvFsVeTHDcxrAspLrEqUHo))):{
															{
																null;
															};
														};
														case sound:{
															{
																director.showCaption(desc, id);
																delay(skipping, Prelude.min(MAX_CAPTION_DURATION, director.getSoundLength(sound)), function() {
																	runWithErrorChecking(function() {
																		{
																			director.hideCaption(id);
																		};
																	}, null);
																});
																true;
															};
														};
														default:{
															null;
														};
													} else null;
												};
											};
										};
										default:{
											null;
										};
									} else null;
								};
							};
						};
						default:{
							null;
						};
					} else null;
				};
			};
		} else null;
	}
	public function miscInt(key:String, ?defaultVal:Int, ?onChange:(Int)->Void):Int  return {
		if (Prelude.truthy(onChange)) {
			miscIntChangeEvents[key] = onChange;
		} else null;
		if (Prelude.truthy(miscInts.exists(key))) miscInts.get(key).value else {
			if (Prelude.truthy(defaultVal)) {
				miscInts.put(key, new JsonInt(defaultVal));
			} else null;
			defaultVal;
		};
	}
	public function miscFloat(key:String, ?defaultVal:Float, ?onChange:(Float)->Void):Float  return {
		if (Prelude.truthy(onChange)) {
			miscFloatChangeEvents[key] = onChange;
		} else null;
		if (Prelude.truthy(miscFloats.exists(key))) miscFloats.get(key).value else {
			if (Prelude.truthy(defaultVal)) {
				miscFloats.put(key, new JsonFloat(defaultVal));
			} else null;
			defaultVal;
		};
	}
	public function resolveDelay(lengthOrKey:Dynamic):Float  return {
		{
			final _smpoQuDg2FcvxsS9NeyWAX:Dynamic = lengthOrKey;
			{
				switch [_smpoQuDg2FcvxsS9NeyWAX] {
					case [sec] if (Prelude.truthy({
						final _hsC83agb7vFXUT7FRVzaYT:Dynamic = Std.isOfType(sec, Float);
						{
							_hsC83agb7vFXUT7FRVzaYT;
						};
					})):{
						{
							final sec:Float = sec;
							{
								sec;
							};
						};
					};
					case [key] if (Prelude.truthy({
						final _sgJxjBpKhvxPRvj7ZttpdZ:Dynamic = Std.isOfType(key, String);
						{
							_sgJxjBpKhvxPRvj7ZttpdZ;
						};
					})):{
						{
							final key:String = key;
							{
								{
									final lengthFloat = delayLengths.get(key).value;
									{
										lastDelay = key;
										lastDelayLength = lengthFloat;
										lengthFloat;
									};
								};
							};
						};
					};
					default:{
						throw kiss.Prelude.runtimeInsertAssertionMessage("case should never match pattern otherwise", "/Users/nat/repos/hollywoo/src/hollywoo/Movie.kiss:1012:13: Assertion failed: \nFrom:[(never otherwise)]", 4);
					};
				};
			};
		};
	}
	public function inputKey() return {
		uuid.Uuid.v4();
	}
	public var currentInputKey = "";
	public function startWaitForInput(cc:Continuation, ?key:String):String  return {
		if (Prelude.truthy(currentInputKey)) {
			director._stopWaitForInput();
		} else null;
		if (Prelude.truthy(!Prelude.truthy(key))) {
			key = inputKey();
		} else null;
		currentInputKey = key;
		director._startWaitForInput(function() return {
			if (Prelude.truthy(!Prelude.truthy(doingSomething))) {
				cc();
			} else null;
		});
		key;
	}
	public function stopWaitForInput(key:String) return {
		if (Prelude.truthy(Prelude.areEqual(currentInputKey, key))) {
			director._stopWaitForInput();
		} else null;
	}
	public function subclassDoPreload():Void  {
		0;
	}
	public function timedTitleCard(skipping:Bool, time:Dynamic, lines:Array<String>, cc:Continuation, ?dontWaitForInput:Bool) return {
		{
			for (line in Prelude.filter(lines)) {
				dialogHistory.push(Super(line));
			};
			null;
		};
		if (Prelude.truthy(skipping)) {
			cc();
			return;
		} else null;
		{
			final inputDelayKey = inputKey();var ccCalled = false;final cc = function() return {
				{
					if (Prelude.truthy(ccCalled)) {
						return;
					} else null;
					ccCalled = true;
					stopWaitForInput(inputDelayKey);
					director.hideTitleCard();
					cc();
				};
			};
			{
				director.showTitleCard(lines, function() {
					runWithErrorChecking(function() {
						{
							startWaitForInput(cc, inputDelayKey);
							delay(skipping, time, cc, true);
						};
					}, cc);
				});
			};
		};
	}
	public function restorePlayMode(cc:Continuation):Void  {
		delayHandling = switch hollywoo.Movie.playMode {
			case _SCU5qzu86L67JtpaGcDtE if (Prelude.truthy(Prelude.isNull(_SCU5qzu86L67JtpaGcDtE))):{
				{
					throw kiss.Prelude.runtimeInsertAssertionMessage("case should never match pattern otherwise", "/Users/nat/repos/hollywoo/src/hollywoo/Movie.kiss:1182:13: Assertion failed: \nFrom:[(never otherwise)]", 4);
				};
			};
			case Read:{
				Manual;
			};
			case Watch:{
				AutoWithSkip;
			};
			default:{
				throw kiss.Prelude.runtimeInsertAssertionMessage("case should never match pattern otherwise", "/Users/nat/repos/hollywoo/src/hollywoo/Movie.kiss:1182:13: Assertion failed: \nFrom:[(never otherwise)]", 4);
			};
		};
		cc();
	}
	public function overridePlayMode(mode:PlayMode, cc:Continuation):Void  {
		delayHandling = switch mode {
			case _qXySVEeh21CzUArTvphNqY if (Prelude.truthy(Prelude.isNull(_qXySVEeh21CzUArTvphNqY))):{
				{
					throw kiss.Prelude.runtimeInsertAssertionMessage("case should never match pattern otherwise", "/Users/nat/repos/hollywoo/src/hollywoo/Movie.kiss:1190:13: Assertion failed: \nFrom:[(never otherwise)]", 4);
				};
			};
			case Read:{
				Manual;
			};
			case Watch:{
				AutoWithSkip;
			};
			default:{
				throw kiss.Prelude.runtimeInsertAssertionMessage("case should never match pattern otherwise", "/Users/nat/repos/hollywoo/src/hollywoo/Movie.kiss:1190:13: Assertion failed: \nFrom:[(never otherwise)]", 4);
			};
		};
		cc();
	}
	public function hideCustomDialog(cc:Continuation):Void  {
		if (Prelude.truthy(_hideCustomDialog)) {
			_hideCustomDialog();
			_hideCustomDialog = null;
		} else null;
		cc();
	}
	public function delay(skipping:Bool, length:Dynamic, cc:Continuation, ?dontWaitForInput:Bool):Void  {
		if (Prelude.truthy(skipping)) {
			cc();
			return;
		} else null;
		{
			final sec = resolveDelay(length);final key = inputKey();
			{
				switch [delayHandling, Prelude.truthy(dontWaitForInput)] {
					case [Auto, _]:{
						TimerWithPause.delay(cc, sec);
					};
					case [AutoWithSkip, _] | [Manual, true]:{
						{
							final autoDelay = TimerWithPause.delay(function() return {
								{
									if (Prelude.truthy(!Prelude.truthy(dontWaitForInput))) {
										stopWaitForInput(key);
									} else null;
									cc();
								};
							}, sec);
							{
								if (Prelude.truthy(!Prelude.truthy(dontWaitForInput))) {
									startWaitForInput(function() return {
										{
											stopWaitForInput(key);
											TimerWithPause.stop(autoDelay);
											cc();
										};
									}, key);
								} else null;
							};
						};
					};
					case [Manual, false]:{
						director.showInputIcon();
						startWaitForInput(function() return {
							{
								director.hideInputIcon();
								stopWaitForInput(key);
								cc();
							};
						}, key);
					};
					default:{
						throw (Prelude.add("Unsupported delay type ", Std.string(delayHandling), "") : String);
					};
				};
			};
		};
	}
	public function watchModeDelay(skipping:Bool, length:Dynamic, cc:Continuation):Void  {
		switch Movie.playMode {
			case _kQsMUMKo73bWwtpq5GQ1zi if (Prelude.truthy(Prelude.isNull(_kQsMUMKo73bWwtpq5GQ1zi))):{
				{
					cc();
				};
			};
			case Watch:{
				delay(skipping, length, cc);
			};
			default:{
				cc();
			};
		};
	}
	public function setSceneSong(scene:String, songKey:String, ?volumeMod:Float, ?cc:Continuation) return {
		sceneMusic[scene] = songKey;
		sceneMusicVolume[scene] = volumeMod;
		if (Prelude.truthy(cc)) {
			cc();
		} else null;
	}
	public function setCurrentSceneSong(skipping:Bool, songKey:String, cc:Continuation, ?volumeMod:Float) return {
		sceneMusic[sceneKey] = songKey;
		sceneMusicVolume[sceneKey] = volumeMod;
		if (Prelude.truthy(Prelude.areEqual(playingSceneMusic, songKey))) {
			changeSongVolume(skipping, volumeMod, cc);
		} else if (Prelude.truthy(true)) {
			playingSceneMusic = songKey;
			stopSong(skipping, function() {
				runWithErrorChecking(function() {
					{
						null;
					};
				}, null);
			});
			loopSong(skipping, songKey, function() {
				runWithErrorChecking(function() {
					{
						null;
					};
				}, null);
			}, volumeMod);
			cc();
		} else null;
	}
	public function setScene(skipping:Bool, name:String, cc:Continuation) return {
		hideCustomDialog(function() {
			runWithErrorChecking(function() {
				{
					_hideCurrentScene(function() {
						runWithErrorChecking(function() {
							{
								{
									final name = FuzzyMapTools.bestMatch(scenes, name);
									{
										sceneKey = name;
										{
											final _9WNVZMdtGeT7cfKnYrSLxL = sceneMusic[name];
											{
												if (Prelude.truthy(_9WNVZMdtGeT7cfKnYrSLxL)) switch _9WNVZMdtGeT7cfKnYrSLxL {
													case _eREE6JVZyxzXrtWWG9NDgC if (Prelude.truthy(Prelude.isNull(_eREE6JVZyxzXrtWWG9NDgC))):{
														{
															if (Prelude.truthy(playingSceneMusic)) {
																playingSceneMusic = null;
																stopSong(skipping, function() {
																	runWithErrorChecking(function() {
																		{
																			null;
																		};
																	}, null);
																});
															} else null;
														};
													};
													case songKey:{
														if (Prelude.truthy(!Prelude.truthy(Prelude.areEqual(playingSceneMusic, songKey)))) {
															playingSceneMusic = songKey;
															stopSong(skipping, function() {
																runWithErrorChecking(function() {
																	{
																		null;
																	};
																}, null);
															});
															loopSong(skipping, songKey, function() {
																runWithErrorChecking(function() {
																	{
																		null;
																	};
																}, null);
															}, sceneMusicVolume[name]);
														} else null;
													};
													default:{
														if (Prelude.truthy(playingSceneMusic)) {
															playingSceneMusic = null;
															stopSong(skipping, function() {
																runWithErrorChecking(function() {
																	{
																		null;
																	};
																}, null);
															});
														} else null;
													};
												} else if (Prelude.truthy(playingSceneMusic)) {
													playingSceneMusic = null;
													stopSong(skipping, function() {
														runWithErrorChecking(function() {
															{
																null;
															};
														}, null);
													});
												} else null;
											};
										};
										if (Prelude.truthy(!Prelude.truthy(positionsInScene.exists(sceneKey)))) {
											positionsInScene[sceneKey] = new kiss.List([]);
										} else null;
										_showScene(scenes[name], appearanceFlag(shownScenes, name), scenes[name].camera, skipping, cc);
									};
								};
							};
						}, cc);
					});
				};
			}, cc);
		});
	}
	public function moveToScene(skipping:Bool, name:String, cc:Continuation) return {
		switch _currentScene() {
			case _aiJrQGdT6PfiiL6cRNFsXE if (Prelude.truthy(Prelude.isNull(_aiJrQGdT6PfiiL6cRNFsXE))):{
				{
					throw kiss.Prelude.runtimeInsertAssertionMessage("case should never match pattern otherwise", "/Users/nat/repos/hollywoo/src/hollywoo/Movie.kiss:1313:9: Assertion failed: \nFrom:[(never otherwise)]", 4);
				};
			};
			case { characters : characters, props : props, propOrder : propOrder, actorAndPropPositionKeys : actorAndPropPositionKeys }:{
				{
					final characters = characters.copy();final props = props.copy();final propOrder = propOrder.copy();final positionKeys = actorAndPropPositionKeys.copy();
					{
						clearCharacters(function() {
							runWithErrorChecking(function() {
								{
									clearProps(function() {
										runWithErrorChecking(function() {
											{
												setScene(skipping, name, function() {
													runWithErrorChecking(function() {
														{
															_ccForEachIterator(characters.keyValueIterator(), function(character, cc) return {
																addCharacter(character.key, character.value.stagePosition, character.value.stageFacing, cc);
															}, function() {
																runWithErrorChecking(function() {
																	{
																		_ccForEach(propOrder, function(propKey, cc) return {
																			addProp(propKey, props.get(propKey).position, cc);
																		}, function() {
																			runWithErrorChecking(function() {
																				{
																					{
																						for (actorOrProp => posKey in actorAndPropPositionKeys) {
																							_currentScene().actorAndPropPositionKeys[actorOrProp] = posKey;
																						};
																						null;
																					};
																					cc();
																				};
																			}, cc);
																		});
																	};
																}, cc);
															});
														};
													}, cc);
												});
											};
										}, cc);
									});
								};
							}, cc);
						});
					};
				};
			};
			default:{
				throw kiss.Prelude.runtimeInsertAssertionMessage("case should never match pattern otherwise", "/Users/nat/repos/hollywoo/src/hollywoo/Movie.kiss:1313:9: Assertion failed: \nFrom:[(never otherwise)]", 4);
			};
		};
	}
	public function playSound(skipping:Bool, name:String, cc:Continuation, ?volumeMod:Float, ?waitForEnd:Bool, ?dontWaitForInput:Bool) return {
		volumeMod = {
			final _9PDPwuFLMVozRgwe8Fw7ir:Dynamic = volumeMod;
			{
				if (Prelude.truthy(_9PDPwuFLMVozRgwe8Fw7ir)) _9PDPwuFLMVozRgwe8Fw7ir else {
					final _3Y7FYQS2dWJZ5aiCTrPimL:Dynamic = 1;
					{
						_3Y7FYQS2dWJZ5aiCTrPimL;
					};
				};
			};
		};
		{
			final _ndQYFpGcpziAyPt4QuWQZB = Prelude.lesserEqual(0, volumeMod, 1);
			{
				if (Prelude.truthy(_ndQYFpGcpziAyPt4QuWQZB)) _ndQYFpGcpziAyPt4QuWQZB else throw kiss.Prelude.runtimeInsertAssertionMessage("", "/Users/nat/repos/hollywoo/src/hollywoo/Movie.kiss:1317:5: Assertion failed: \nFrom:[(assert (<= 0 volumeMod 1))]", 4);
			};
		};
		{
			final name = FuzzyMapTools.bestMatch(sounds, name);
			{
				final looping = Prelude.truthy(loopingSoundPlays[name]);
				{
					final _oNJnujAATYmWXhBSYEhyec = soundDescriptions[name];
					{
						if (Prelude.truthy(_oNJnujAATYmWXhBSYEhyec)) switch _oNJnujAATYmWXhBSYEhyec {
							case _aqszeT4RsPBFQFC37oHSnJ if (Prelude.truthy(Prelude.isNull(_aqszeT4RsPBFQFC37oHSnJ))):{
								{
									null;
								};
							};
							case desc:{
								{
									dialogHistory.push(Sound(desc));
								};
							};
							default:{
								null;
							};
						} else null;
					};
				};
				if (Prelude.truthy(skipping)) {
					cc();
					return;
				} else null;
				if (Prelude.truthy(!Prelude.truthy(looping))) {
					handleCaption(skipping, name);
				} else null;
				{
					final sound = sounds[name];final inputDelayKey = inputKey();
					{
						{
							function innerCC() {
								if (Prelude.truthy(!Prelude.truthy(looping))) {
									director.stopSound(sound);
									if (Prelude.truthy(!Prelude.truthy(dontWaitForInput))) {
										stopWaitForInput(inputDelayKey);
									} else null;
								} else null;
								cc();
							};
							if (Prelude.truthy(!Prelude.truthy({
								final _iMK9GnBfEECzuagB3nczTR:Dynamic = looping;
								{
									if (Prelude.truthy(_iMK9GnBfEECzuagB3nczTR)) _iMK9GnBfEECzuagB3nczTR else {
										final _dEjx1Zdp2cYryRrFscWuzo:Dynamic = dontWaitForInput;
										{
											_dEjx1Zdp2cYryRrFscWuzo;
										};
									};
								};
							}))) {
								if (Prelude.truthy(waitForEnd)) {
									startWaitForInput(innerCC, inputDelayKey);
								} else null;
							} else null;
							director.playSound(sound, volumeMod, if (Prelude.truthy(waitForEnd)) {
								innerCC;
							} else null);
						};
					};
				};
				if (Prelude.truthy(!Prelude.truthy(waitForEnd))) {
					cc();
				} else null;
			};
		};
	}
	public function awaitPlaySound(skipping:Bool, name:String, cc:Continuation, ?volumeMod:Float) return {
		playSound(skipping, name, cc, volumeMod, true);
	}
	public function awaitPlaySounds(skipping:Bool, names:Array<String>, cc:Continuation, ?volumeMod:Float) return {
		{
			final names = names.copy();final inputDelayKey = inputKey();
			{
				var currentSound = "";
				final endCC = function() {
					runWithErrorChecking(function() {
						{
							stopWaitForInput(inputDelayKey);
							while (true) {
								{
									final _tB4QTt1vaLayu3aSjMz1sD = names.shift();
									{
										if (Prelude.truthy(_tB4QTt1vaLayu3aSjMz1sD)) switch _tB4QTt1vaLayu3aSjMz1sD {
											case _L4TD8xWT5YynxSfPZ2F7H if (Prelude.truthy(Prelude.isNull(_L4TD8xWT5YynxSfPZ2F7H))):{
												{
													break;
												};
											};
											case soundKey:{
												{
													playSound(true, soundKey, function() {
														runWithErrorChecking(function() {
															{
																null;
															};
														}, null);
													}, volumeMod, false, true);
												};
											};
											default:{
												break;
											};
										} else break;
									};
								};
							};
							if (Prelude.truthy(currentSound)) {
								stopSound(skipping, currentSound, cc);
							} else null;
							cc();
						};
					}, cc);
				};
				if (Prelude.truthy(skipping)) {
					endCC();
					return;
				} else null;
				startWaitForInput(endCC, inputDelayKey);
				_ccForEach(names, function(name, cc) return {
					{
						currentSound = name;
						playSound(skipping, name, cc, volumeMod, true, true);
					};
				}, endCC);
			};
		};
	}
	public function stopSound(skipping:Bool, name:String, cc:Continuation) return {
		{
			final name = FuzzyMapTools.bestMatch(sounds, name);
			{
				loopingSoundPlays.remove(name);
				if (Prelude.truthy(!Prelude.truthy(skipping))) {
					director.stopSound(sounds[name]);
				} else null;
			};
		};
		cc();
	}
	public function loopSound(skipping:Bool, name:String, cc:Continuation, ?volumeMod:Float, ?decay:Float) return {
		if (Prelude.truthy(!Prelude.truthy(volumeMod))) {
			volumeMod = 1;
		} else null;
		if (Prelude.truthy(!Prelude.truthy(decay))) {
			decay = 0;
		} else null;
		if (Prelude.truthy({
			final _diedPeaUJRBm2godRAPUh3:Dynamic = skipping;
			{
				if (Prelude.truthy(_diedPeaUJRBm2godRAPUh3)) {
					final _j9VmT22Vs63JgHLCSZMWhY:Dynamic = Prelude.greaterThan(decay, 0);
					{
						_j9VmT22Vs63JgHLCSZMWhY;
					};
				} else _diedPeaUJRBm2godRAPUh3;
			};
		})) {
			cc();
			return;
		} else null;
		var vm = Prelude.add(volumeMod, decay);
		{
			final name = FuzzyMapTools.bestMatch(sounds, name);
			{
				{
					function playAgain() {
						vm = Prelude.subtract(vm, decay);
						if (Prelude.truthy({
							final _oT58UfkTskTcZaDu5d882R:Dynamic = Prelude.greaterThan(decay, 0);
							{
								if (Prelude.truthy(_oT58UfkTskTcZaDu5d882R)) {
									final _coE77L9dbhD9F8t7dXma1Y:Dynamic = Prelude.lessThan(vm, 0);
									{
										_coE77L9dbhD9F8t7dXma1Y;
									};
								} else _oT58UfkTskTcZaDu5d882R;
							};
						})) {
							loopingSoundPlays.remove(name);
							return;
						} else null;
						playSound(false, name, function() {
							runWithErrorChecking(function() {
								{
									if (Prelude.truthy(loopingSoundPlays.exists(name))) {
										playAgain();
									} else null;
								};
							}, null);
						}, vm, true);
					};
					handleCaption(skipping, name);
					loopingSoundPlays[name] = playAgain;
					if (Prelude.truthy(!Prelude.truthy(skipping))) {
						playAgain();
					} else null;
				};
			};
		};
		cc();
	}
	public function playSong(skipping:Bool, name:String, cc:Continuation, ?volumeMod:Float, ?loop:Bool, ?waitForEnd:Bool) return {
		volumeMod = {
			final _NAtEC1XtXVqZD9pJZ6P21:Dynamic = volumeMod;
			{
				if (Prelude.truthy(_NAtEC1XtXVqZD9pJZ6P21)) _NAtEC1XtXVqZD9pJZ6P21 else {
					final _e5ACvZeVhg5V3e9XSNrhF7:Dynamic = 1;
					{
						_e5ACvZeVhg5V3e9XSNrhF7;
					};
				};
			};
		};
		{
			final _htPsCTKhbgg3MFmDZsZucm = Prelude.lesserEqual(0, volumeMod, 1);
			{
				if (Prelude.truthy(_htPsCTKhbgg3MFmDZsZucm)) _htPsCTKhbgg3MFmDZsZucm else throw kiss.Prelude.runtimeInsertAssertionMessage("", "/Users/nat/repos/hollywoo/src/hollywoo/Movie.kiss:1415:5: Assertion failed: \nFrom:[(assert (<= 0 volumeMod 1))]", 4);
			};
		};
		currentSong = FuzzyMapTools.bestMatch(songs, name);
		currentSongVolumeMod = volumeMod;
		currentSongLooping = Prelude.truthy(loop);
		if (Prelude.truthy(skipping)) {
			cc();
			return;
		} else null;
		director.playSong(songs[currentSong], volumeMod, Prelude.truthy(loop), Prelude.truthy(waitForEnd), cc);
	}
	public function changeSongVolume(skipping:Bool, volumeMod:Float, cc:Continuation) return {
		currentSongVolumeMod = volumeMod;
		if (Prelude.truthy(skipping)) {
			cc();
			return;
		} else null;
		director.changeSongVolume(volumeMod, cc);
	}
	public function awaitPlaySong(skipping:Bool, name:String, cc:Continuation, ?volumeMod:Float) return {
		if (Prelude.truthy(skipping)) {
			cc();
			return;
		} else null;
		playSong(skipping, name, cc, volumeMod, false, true);
	}
	public function loopSong(skipping:Bool, name:String, cc:Continuation, ?volumeMod:Float) return {
		playSong(skipping, name, cc, volumeMod, true, false);
	}
	public function stopSong(skipping:Bool, cc) return {
		currentSong = "";
		if (Prelude.truthy(!Prelude.truthy(skipping))) {
			director.stopSong();
		} else null;
		cc();
	}
	public function autoZProcess(position:StagePosition, cc:Continuation) return {
		{
			final _dJog5TLuubGSepAf6Yv52h = director.autoZConfig();
			{
				if (Prelude.truthy(_dJog5TLuubGSepAf6Yv52h)) switch _dJog5TLuubGSepAf6Yv52h {
					case _m5gjwSEZaMqQ1j92Lg8nuw if (Prelude.truthy(Prelude.isNull(_m5gjwSEZaMqQ1j92Lg8nuw))):{
						{
							cc();
						};
					};
					case Some({ zPerLayer : zPerLayer, frontLayer : frontLayer }):{
						{
							{
								for (name => otherCharacter in _currentScene().characters) {
									if (Prelude.truthy({
										final _a29gFUzobZtiL5ux6xAD3Z:Dynamic = Prelude.areEqual(position.x, otherCharacter.stagePosition.x);
										{
											if (Prelude.truthy(_a29gFUzobZtiL5ux6xAD3Z)) {
												final _kKssVs2zAn2iqHavBbMnLX:Dynamic = Prelude.areEqual(position.y, otherCharacter.stagePosition.y);
												{
													if (Prelude.truthy(_kKssVs2zAn2iqHavBbMnLX)) {
														final _hXBcF1yMKuYSwMQSSsZHUf:Dynamic = Prelude.areEqual(position.z, otherCharacter.stagePosition.z);
														{
															_hXBcF1yMKuYSwMQSSsZHUf;
														};
													} else _kKssVs2zAn2iqHavBbMnLX;
												};
											} else _a29gFUzobZtiL5ux6xAD3Z;
										};
									})) {
										moveCharacter(name, new StagePosition(position.x, position.y, Prelude.add(otherCharacter.stagePosition.z, zPerLayer)), otherCharacter.stageFacing, cc);
										return;
									} else null;
								};
								null;
							};
							cc();
						};
					};
					default:{
						cc();
					};
				} else cc();
			};
		};
	}
	public function addCharacter(actorName, position:Dynamic, facing:StageFacing, cc:Continuation) return {
		{
			final actorName = FuzzyMapTools.bestMatch(actors, actorName);final position = resolvePosition(position, actorName);final character = { stagePosition : position, stageFacing : facing, actor : actors[actorName] };
			{
				autoZProcess(position, function() {
					runWithErrorChecking(function() {
						{
							_currentScene().characters[actorName] = character;
							_updateLighting();
							director.showCharacter(character, appearanceFlag(shownCharacters, actorName), _currentScene().camera, cc);
						};
					}, cc);
				});
			};
		};
	}
	public function removeCharacter(actorName, cc:Continuation) return {
		{
			final c = _currentScene().characters[actorName];
			{
				_currentScene().characters.remove(actorName);
				_updateLighting();
				director.hideCharacter(c, _currentScene().camera, cc);
			};
		};
	}
	public function clearCharacters(cc:Continuation) return {
		{
			for (name => c in _currentScene().characters) {
				director.hideCharacter(c, _currentScene().camera, function() {
					runWithErrorChecking(function() {
						{
							null;
						};
					}, null);
				});
				_currentScene().characters.remove(name);
			};
			null;
		};
		_updateLighting();
		cc();
	}
	public function moveCharacter(actorName, newPosition:Dynamic, newFacing:StageFacing, cc:Continuation) return {
		removeCharacter(actorName, function() {
			runWithErrorChecking(function() {
				{
					addCharacter(actorName, newPosition, newFacing, cc);
				};
			}, cc);
		});
	}
	public function swapCharacters(actorNameA, actorNameB, cc:Continuation) return {
		{
			final a = _currentScene().characters[actorNameA];final asp = a.stagePosition;final asf = a.stageFacing;final b = _currentScene().characters[actorNameB];final bsp = b.stagePosition;final bsf = b.stageFacing;
			{
				removeCharacter(actorNameA, function() {
					runWithErrorChecking(function() {
						{
							removeCharacter(actorNameB, function() {
								runWithErrorChecking(function() {
									{
										addCharacter(actorNameA, bsp, bsf, function() {
											runWithErrorChecking(function() {
												{
													addCharacter(actorNameB, asp, asf, cc);
												};
											}, cc);
										});
									};
								}, cc);
							});
						};
					}, cc);
				});
			};
		};
	}
	public function strobeCharacter(skipping:Bool, actorName:String, sec:Float, times:Int, cc:Continuation) return {
		_strobe(skipping, false, actorName, sec, times);
		cc();
	}
	public function strobeProp(skipping:Bool, propName:String, sec:Float, times:Int, cc:Continuation) return {
		_strobe(skipping, true, propName, sec, times);
		cc();
	}
	public function awaitStrobeCharacter(skipping:Bool, actorName:String, sec:Float, times:Int, cc:Continuation) return {
		_strobe(skipping, false, actorName, sec, times, cc);
	}
	public function awaitStrobeProp(skipping:Bool, propName:String, sec:Float, times:Int, cc:Continuation) return {
		_strobe(skipping, true, propName, sec, times, cc);
	}
	public function addProp(name, position:Dynamic, cc:Continuation) return {
		{
			final name = FuzzyMapTools.bestMatch(props, name);final prop = props[name];final position = resolvePosition(position, name);
			{
				if (Prelude.truthy(_currentScene().propOrder.contains(name))) {
					_currentScene().propOrder.remove(name);
				} else null;
				_currentScene().propOrder.push(name);
				_currentScene().props[name] = { position : position, prop : prop };
				_updateLighting();
				director.showProp(prop, position, appearanceFlag(shownProps, name), _currentScene().camera, cc);
			};
		};
	}
	public function removeProp(name, cc:Continuation) return {
		{
			final name = FuzzyMapTools.bestMatch(props, name);
			{
				_currentScene().propOrder.remove(name);
				_currentScene().props.remove(name);
				_updateLighting();
				director.hideProp(props[name], _currentScene().camera, cc);
			};
		};
	}
	public function clearProps(cc:Continuation) return {
		_currentScene().propOrder = new kiss.List([]);
		_ccForEach([for (elem in _currentScene().props.keys()) {
			elem;
		}], function(name, cc) return {
			removeProp(name, cc);
		}, cc);
	}
	public function intercut(actorNamesToSceneNames:Map<String,String>, cc:Continuation) return {
		intercutMap = new FuzzyMap<String>();
		{
			for (actor => scene in actorNamesToSceneNames) {
				intercutMap[actor] = scene;
			};
			null;
		};
		cc();
	}
	public function endIntercut(cc:Continuation) return {
		intercutMap = null;
		cc();
	}
	public function showTitleCard(lines:Array<String>, cc:Continuation) return {
		{
			for (line in Prelude.filter(lines)) {
				dialogHistory.push(Super(line));
			};
			null;
		};
		director.showTitleCard(lines, cc);
		cc();
	}
	public function hideTitleCard(cc:Continuation) return {
		director.hideTitleCard();
		cc();
	}
	public function superText(skipping:Bool, text, cc:Continuation) return {
		dialogHistory.push(Super(text));
		if (Prelude.truthy(skipping)) cc() else showDialog(skipping, "", Super, "", text, cc);
	}
	public function timedSuperText(skipping:Bool, text, sec:Dynamic, cc:Continuation) return {
		if (Prelude.truthy(skipping)) {
			dialogHistory.push(Super(text));
			cc();
			return;
		} else null;
		{
			final cc = function() {
				{
					director._hideDialog();
					cc();
				};
			};
			{
				superText(skipping, text, cc);
				delay(skipping, sec, cc, true);
			};
		};
	}
	public function normalSpeech(skipping:Bool, actorName, wryly, text, cc:Continuation) return {
		processIntercut(skipping, actorName, function() {
			runWithErrorChecking(function() {
				{
					{
						final character = _currentScene().characters[actorName];final actor = character.actor;
						{
							director.showExpression(actor, wryly);
							showDialog(skipping, actorName, OnScreen(character), wryly, text, cc);
						};
					};
				};
			}, cc);
		});
	}
	public function interruptedSpeech(skipping:Bool, actorName, wryly, text:String, cc:Continuation) return {
		overridePlayMode(Watch, function() {
			runWithErrorChecking(function() {
				{
					null;
				};
			}, null);
		});
		{
			final wrappedCC = function() {
				runWithErrorChecking(function() {
					{
						restorePlayMode(cc);
					};
				}, cc);
			};final slashIndex = text.lastIndexOf("/");
			{
				if (Prelude.truthy(Prelude.areEqual(-1, slashIndex))) {
					throw "interruptedSpeech requires a / in the text to indicate the cutoff point!";
				} else null;
				{
					final slashPercent = Prelude.divide(slashIndex, text.length);final text = (Prelude.add("", Std.string(text.substr(0, slashIndex)), "", Std.string(text.substr(Prelude.add(1, slashIndex))), "") : String);final text = StringTools.replace(text, "  ", " ");final text = StringTools.replace(text, "  ", " ");
					{
						processIntercut(skipping, actorName, function() {
							runWithErrorChecking(function() {
								{
									{
										final character = _currentScene().characters[actorName];final actor = character.actor;
										{
											director.showExpression(actor, wryly);
											showDialog(skipping, actorName, OnScreen(character), wryly, text, wrappedCC, slashPercent);
										};
									};
								};
							}, cc);
						});
					};
				};
			};
		};
	}
	public function offScreenSpeech(skipping:Bool, actorName, wryly, text, cc:Continuation) return {
		{
			final actor = actors[actorName];
			{
				director.showExpression(actor, wryly);
				showDialog(skipping, actorName, OffScreen(actor), wryly, text, cc);
			};
		};
	}
	public function voiceOver(skipping:Bool, actorName, wryly, text, cc:Continuation) return {
		showDialog(skipping, actorName, VoiceOver(actors[actorName]), wryly, text, cc);
	}
	public function onPhoneSpeech(skipping:Bool, actorName, wryly, text, cc:Continuation) return {
		processIntercut(skipping, actorName, function() {
			runWithErrorChecking(function() {
				{
					showDialog(skipping, actorName, {
						final _tDuE9XG2d54dz1F8AFZjVH = try _currentScene().characters[actorName] catch(e) {
							null;
						};
						{
							if (Prelude.truthy(_tDuE9XG2d54dz1F8AFZjVH)) switch _tDuE9XG2d54dz1F8AFZjVH {
								case _hMKp5RiGS9CtmLnX1HF1JA if (Prelude.truthy(Prelude.isNull(_hMKp5RiGS9CtmLnX1HF1JA))):{
									{
										FromPhone(actors[actorName]);
									};
								};
								case charOnScreen:{
									{
										director.showExpression(charOnScreen.actor, wryly);
										OnScreen(charOnScreen);
									};
								};
								default:{
									FromPhone(actors[actorName]);
								};
							} else FromPhone(actors[actorName]);
						};
					}, wryly, text, cc);
				};
			}, cc);
		});
	}
	public function customSpeech(skipping:Bool, type, actorName, wryly, args, text, cc:Continuation) return {
		processIntercut(skipping, actorName, function() {
			runWithErrorChecking(function() {
				{
					showDialog(skipping, actorName, Custom(type, _currentScene().characters[actorName], args), wryly, text, cc);
				};
			}, cc);
		});
	}
	public function timedCutToBlack(skipping:Bool, seconds:Dynamic, cc:Continuation) return {
		if (Prelude.truthy(skipping)) {
			cc();
			return;
		} else null;
		director.showBlackScreen();
		delay(skipping, seconds, function() {
			{
				director.hideBlackScreen();
				cc();
			};
		}, true);
	}
	public function cutToBlack(cc:Continuation) return {
		director.showBlackScreen();
		cc();
	}
	public function endCutToBlack(cc:Continuation) return {
		director.hideBlackScreen();
		cc();
	}
	public function rollCredits(skipping:Bool, creditsTSV:String, cc:Continuation, ?timeLimit:Float) return {
		if (Prelude.truthy(skipping)) {
			cc();
			return;
		} else null;
		director.rollCredits({
			final creditsData = [for (line in Stream.fromString(creditsTSV).content.split("\n")) {
				line.split("\t");
			}];final headings = new kiss.List([]);final edgeCaseCredits = new Map<String, String>();final headingIndices = new Map<String, Int>();final headingData = new Map<String, Array<Array<String>>>();
			{
				{
					for (_5bu9XrYtitFLoNL1fK37sX in Prelude.enumerate(creditsData)) {
						final _qshQu1j2CUjTSSARRhQJYF = _5bu9XrYtitFLoNL1fK37sX;final idx = _qshQu1j2CUjTSSARRhQJYF[0];final data = _qshQu1j2CUjTSSARRhQJYF[1];
						{
							switch data {
								case _LFL7Cwggf3uVqKYRUERq2 if (Prelude.truthy(Prelude.isNull(_LFL7Cwggf3uVqKYRUERq2))):{
									{ };
								};
								case [heading] | [heading, ""]:{
									headings.push(heading);
									headingIndices[heading] = idx;
									headingData[heading] = new kiss.List([]);
								};
								case ["", heading] if (Prelude.truthy(StringTools.endsWith(heading, ":"))):{
									headings.push(Prelude.substr(heading, 0, -1));
									headingIndices[Prelude.substr(heading, 0, -1)] = idx;
									headingData[Prelude.substr(heading, 0, -1)] = new kiss.List([]);
								};
								default:{ };
							};
						};
					};
					null;
				};
				{
					for (_auRLPL4X68eW3uZaASrmrx in Prelude.enumerate(loadedCredits)) {
						final _uqpP6413SZD3CBZ3zhC86Q = _auRLPL4X68eW3uZaASrmrx;final idx = _uqpP6413SZD3CBZ3zhC86Q[0];final data = _uqpP6413SZD3CBZ3zhC86Q[1];
						{
							final creditSource = loadedCreditSources[idx];
							switch data {
								case _baACrMoQ31DTX1dz9gqSJo if (Prelude.truthy(Prelude.isNull(_baACrMoQ31DTX1dz9gqSJo))):{
									{
										throw ((Prelude.add("unsupported credit data ", Std.string(data), " from ", Std.string(creditSource), "") : String));
									};
								};
								case [heading, credit, _sourceOrUrl]:{
									{
										final _tL31jrnJFvuFa5MLt6PALy = headingIndices[heading];
										{
											if (Prelude.truthy(_tL31jrnJFvuFa5MLt6PALy)) switch _tL31jrnJFvuFa5MLt6PALy {
												case _a4N2m1LrnX5rL2iMXJvggB if (Prelude.truthy(Prelude.isNull(_a4N2m1LrnX5rL2iMXJvggB))):{
													{
														throw ((Prelude.add("no heading ", Std.string(heading), " to place credit ", Std.string(data), " from ", Std.string(creditSource), "") : String));
													};
												};
												case idx:{
													{
														final edgeCaseCredit = edgeCaseCredits[heading];final hd = headingData[heading];final hdPush = function(data) {
															{
																final dataStr = data.toString();
																{
																	if (Prelude.truthy(Prelude.areEqual(credit, edgeCaseCredit))) {
																		return;
																	} else null;
																	{
																		for (d in hd) {
																			if (Prelude.truthy(Prelude.areEqual(d.toString(), dataStr))) {
																				return;
																			} else null;
																		};
																		null;
																	};
																	hd.push(data);
																};
															};
														};final headingLineData = creditsData[idx];
														{
															switch headingLineData {
																case _rZxbXNtpWENV9b7FjWuKpi if (Prelude.truthy(Prelude.isNull(_rZxbXNtpWENV9b7FjWuKpi))):{
																	{
																		throw kiss.Prelude.runtimeInsertAssertionMessage("case should never match pattern otherwise", "/Users/nat/repos/hollywoo/src/hollywoo/Movie.kiss:1720:41: Assertion failed: \nFrom:[(never otherwise)]", 4);
																	};
																};
																case [heading, ""]:{
																	edgeCaseCredits[heading] = credit;
																	headingLineData[1] = credit;
																};
																case ["", heading]:{
																	hdPush(new kiss.List(["", (Prelude.add("   ", Std.string({
																		credit;
																	}), "") : String)]));
																};
																case [heading] | [heading, _]:{
																	hdPush(new kiss.List(["", credit]));
																};
																default:{
																	throw kiss.Prelude.runtimeInsertAssertionMessage("case should never match pattern otherwise", "/Users/nat/repos/hollywoo/src/hollywoo/Movie.kiss:1720:41: Assertion failed: \nFrom:[(never otherwise)]", 4);
																};
															};
														};
													};
												};
												default:{
													throw (Prelude.add("no heading ", Std.string(heading), " to place credit ", Std.string(data), " from ", Std.string(creditSource), "") : String);
												};
											} else throw (Prelude.add("no heading ", Std.string(heading), " to place credit ", Std.string(data), " from ", Std.string(creditSource), "") : String);
										};
									};
								};
								default:{
									throw (Prelude.add("unsupported credit data ", Std.string(data), " from ", Std.string(creditSource), "") : String);
								};
							};
						};
					};
					null;
				};
				{
					for (heading in Prelude.reverse(headings)) {
						{
							final idx = headingIndices[heading];final hd = headingData[heading];
							{
								{
									for (data in Prelude.reverse(hd)) {
										creditsData.insert(Prelude.add(idx, 1), data);
									};
									null;
								};
							};
						};
					};
					null;
				};
				[for (data in creditsData) {
					switch data {
						case _j1RLLj5myCBYoHZCm4b4Ef if (Prelude.truthy(Prelude.isNull(_j1RLLj5myCBYoHZCm4b4Ef))):{
							{
								throw ((Prelude.add("unsupported credits line ", Std.string(data), "") : String));
							};
						};
						case []:{
							Break;
						};
						case [col1]:{
							OneColumn(col1);
						};
						case [col1, col2]:{
							TwoColumn(col1, col2);
						};
						case [col1, col2, col3]:{
							ThreeColumn(col1, col2, col3);
						};
						default:{
							throw (Prelude.add("unsupported credits line ", Std.string(data), "") : String);
						};
					};
				}];
			};
		}, cc, timeLimit);
	}
	public function themedRollCredits(skipping:Bool, creditsTSV:String, songKey:String, cc:Continuation, ?volumeMod:Float) return {
		if (Prelude.truthy(skipping)) {
			cc();
			return;
		} else null;
		playSong(skipping, songKey, function() {
			runWithErrorChecking(function() {
				{
					null;
				};
			}, null);
		}, volumeMod);
		rollCredits(skipping, creditsTSV, function() {
			runWithErrorChecking(function() {
				{
					stopSong(skipping, cc);
				};
			}, cc);
		}, director.getSongLength(songs[songKey]));
	}
	// END KISS FOSSIL CODE
}
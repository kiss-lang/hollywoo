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
import kiss_tools.JsonableArray;
import kiss_tools.JsonableString;
import kiss_tools.TimerWithPause;

using kiss.FuzzyMapTools;

typedef Cloneable<T> = {
    function clone():T;
}

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
@:build(kiss.Kiss.build())
class Movie<Set:Cloneable<Set>, Actor, Sound, Song, Prop, VoiceTrack, Camera, LightSource:Jsonable<LightSource>> extends AsyncEmbeddedScript2 {}

as3recording 是一个事件记录和回放的框架。as3recording 可以运行在记录模式或回放模式。以记录模式运行时，as3recording 能把程序运行过程中发生的事件以 XML 格式，通过 HTTP 的 PUT 或 POST 方法发到你指定的网址上。以回放模式运行时，as3recording 从一个网址下载 XML 格式的录像，把先前记录在录像中的事件按顺序触发。

as3recording 主要用于大型flash项目的调试，可重现各类bug。也可把录像文件暴露给用户，直接向用户提供录像功能。

# 求助 #

as3recording 是一个开源项目，欢迎任何人加入。你可以参与的工作包括：
  * 增加新的功能
  * 撰写教程
  * 将本文翻译为英文
如果你希望提交代码或撰写文档，请直接[创建issue](http://code.google.com/p/as3recording/issues/entry)。

# 用法 #

```
package {
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import com.netease.recording.*;

    public class MyApplication extends Sprite
    {
        static const URL:String = "http://your-domain.com:8080/replay.xml";

        private var recorder:IRecorder;

        public function MyApplication()
        {
            if (loaderInfo.parameters.isReplay)
            {
                // 回放模式
                recorder = new ReplayManager(new URLRequest(URL));
                addEventListener(Event.ADDED_TO_STAGE, function(event:Event):void
                {
                    stage.frameRate = stage.frameRate * 10;
                });
                addEventListener(Event.ADDED_TO_STAGE, function(event:Event):void
                {
                    recorder.start(stage);
                });
            }
            else
            {
                // 记录模式
                const poster:ChunkedHTTPPoster = new ChunkedHTTPPoster();
                poster.open(new PosterURLRequest(URL));
                recorder = new RecordManager();
                RecordManager(recorder).writeFunction = poster.writeChunk;
                poster.addEventListener(Event.CONNECT, function(event:Event):void
                {
                    recorder.start(stage);
                });
            }

            // your program initialize...
        }
    }
}
```
注意，上述代码仅仅是客户端代码，要让上述代码正常工作，你还需要一个 Web 服务器来处理对 _http://your-domain.com:8080/replay.xml_ 的请求。

调用 `recorder.start(stage)` 后，如果在记录模式，则 as3recording 会记录该 Stage 下所有显示对象的键盘、鼠标、焦点、文本等事件。而如果在回放模式，则 as3recording 会在该 Stage 下的显示对象按顺序回放录像文件中记录的键盘、鼠标、焦点、文本事件。

记录时和回放时的帧率不必相同，比如 `stage.frameRate = stage.frameRate * 10;` 这行代码就让回放时的帧率提高了 10 倍，同时也让播放速度提高了 10 倍。这是因为录像中记录的事件都与帧同步。帧率提高，发生事件的频率也随之提高。
## 非 `DisplayObject` 对象上的事件 ##
在 `DisplayObject` 以外的对象上发生的事件，不会被 Stage 截获。所以在 `flash.display.LoaderInfo` 、 `flash.utils.Timer` 等类上触发的事件不会被录下。与此类似， `flash.utils.setTimemout` 和 `flash.utils.setInterval` 的回调函数调用也不会被记录。

尽管 `flash.display.LoaderInfo` 、 `flash.utils.Timer` 不支持录像，但可以使用 `IRecorder.newInstance` 方法创建出支持录像的定时器和加载器。例如：
```
import com.netease.recording.ITimer;
import flash.events.TimerEvent;
var timer:ITimer = recorder.newInstance(ITimer, 1000);
timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void
{
    trace("timer");
});
timer.start();
```
以及
```
import com.netease.recording.ILoader;
import com.netease.recording.ILoaderInfo;
import flash.events.Event;
import flash.net.URLRequest;
var loader:ILoader = recorder.newInstance(ILoader);
var loaderInfo:ILoaderInfo = loader.contentILoaderInfo;
loaderInfo.addEventListener(Event.COMPLETE, function(event:Event):void
{
    trace("complete");
});
loader.load(new URLRequest("my/url.swf"));
addChild(loader.asDisplayObject());
```
ILoader 上的方法、属性都和原生 Loader 是保持一致，而 ITimer 上的方法、属性也和 Timer 一样。仅有的例外是 `ILoader.asDisplayObject()` 和 `ILoader.contentILoaderInfo`。前者是因为 ILoader 作为一个接口，无法像 Loader 一样作为显示对象添加到显示列表中。如果要把 ILoader 显示出来，需要调用 `ILoader.asDisplayObject()` 把它视为一个显示对象来用。后者是因为原生的 contentLoaderInfo 会返回不支持录像 `LoaderInfo` ，而 contentILoaderInfo 则返回包装后的 ILoaderInfo。ILoaderInfo 上发生的事件可以被记录和回放。

# 扩展 #
使用 `RecordManager` 和 `ReplayManager` 能够记录和回放的事件仅限于添加到 Stage 的显示对象以及 newInstance 方法创建出的 ITimer 或 ILoader。如果需要支持更多类型的对象和事件，需要自己编写插件。

要想实现一个支持录像的接口需要编写两个插件类。为了支持记录，要实现 IRecordPlugin 接口，然后把实现类通过 `RecordManager.addPlugin` 进行注册。而回放时，则要实现 IReplayPlugin 接口，然后调用 `ReplayManager.addPlugin` 进行注册。
# 限制 #
as3recording 尽力做到让回放时和记录时能执行相同的代码。然而，这需要对你的代码编写做一些限制。如果你编写了一些记录时和回放时可能导致不同行为的代码，那么 as3recording 就无法正常工作。以下是这些限制：
## 广播事件 ##
as3recording 对所有的广播事件都无法记录和回放。不过幸运的是，因为回放时的事件都是与 Stage 上的 enterFrame 、 exitFrame 、 frameConstructed 事件对齐顺序的，所以如果记录时，在 Stage 上的 enterFrame 、 exitFrame 、 frameConstructed 注册了一些事件处理函数，回放时仍然能保证这些函数以相同的顺序被执行。
## Math.random() ##
Math.random() 不是通过事件触发的，所以 as3recording 不能保证回放时和记录时产生的随机数一致。如果需要生成随机数，请使用 `IRecorder.random()` ，`IRecorder.random()` 能保证回放时和记录时产生相同的随机数。
## `SharedObject` ##
如果回放时和记录时本地保存的 `SharedObject` 不同，则也可能会导致出错。
## Socket 和 XMLSocket ##
就像 Loader 和 Timer 一样，直接使用 Socket 和 XMLSocket 也无法支持录像。和 Loader 和 Timer 的区别在于 as3recording 并未内置支持录像的套接字，你需要自己实现相应的插件。建议你不要在 Socket 级别实现支持录像的接口，而是基于你自己的网络协议，在更高的层次实现录像。
## ILoaderInfo ##
只要你使用了 ILoaderInfo ，就能保证记录时发生的 init、ioError、complete 等事件都能在回放时以相同的顺序发生。然而，回放时即使触发了 complete ，也并不代表 `ILoaderInfo.content` 就能用了。如果你编写的代码依赖于 content 属性，那么就只有回放时的网速大于等于记录时录像才能正确回放。在 Standalone 的 Flash Player 中，用 file:// 协议加载的文件能保证这一点。
## `BitmapData.draw()` ##
如果调用 `BitmapData.draw()` 进行截图，并不保证能获得相同的像素。因为 as3recording 的目标是做到记录时和回放时执行相同的代码，但不保证记录时和回放时的实际显示效果一致。比如 `SimpleButton` 上 upState 、 downState 等状态的切换并不由 ActionScript 干预（也不通知 ActionScript），而是 Flash Player 的引擎做的事情。具体的说，记录时，如果鼠标按住某个 `SimpleButton` ，那么这个 `SimpleButton` 会显示为 downState ，并触发 mouseDown 事件。回放时，`ReplayManager` 会模拟录像中的 `mouseDown` 事件，所以 mouseDown 事件触发的代码依然会执行。然而回放时该 `SimpleButton` 并不会自动显示为 downState 。
## `for ... in` 和 `for each .. in` ##
用 `for ... in` 和 `for each .. in` 列举成员时，顺序未定义。所以有可能记录时和回放时的顺序不同，而导致不同的执行结果。如果一定要使用 `for ... in` 和 `for each ... in` ，其中的代码必须尽量短小，不应该影响程序执行流程，也不要在其中的代码上执行 IRecorder.newInstance() 等与 as3recording 交互的代码。
## 不在 Stage 中的 `DisplayObject` ##
as3recording 通过 Stage 来截获显示对象上的事件。如果某个显示对象尚未添加到 Stage 中，或者已经从 Stage 上移除，那么它上面发生的事件就无法被记录下来。比如：
```
const myButton:SimpleButton = ...
addChild(myButton);
myButton.addEventListener(MouseEvent.ROLL_OUT, function(event:MouseEvent):void
{
	// 注意！回放录像时，最后一次鼠标点击并不会触发此处的 ROLL_OUT 处理代码。
	// 因为 ROLL_OUT 事件是在 myButton 已经被移除出显示列表以后才发生的，
	// 所以 as3recording 无法截获和记录该事件。
	trace("rollOut");
});
myButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void
{
	myButton.parent.removeChild(myButton);
});
```

每当鼠标移出 myButton 时，就会 trace 一行文字。记录录像的过程中，当你最后一次点击 myButton 时，也会触发一次 rollOut 事件。然而，最后这一次 rollOut 事件并不会被记录下来，因为 myButton 那时候已经不在 Stage 中了。所以，回放录像时，最后的这次 rollOut 不会触发。这有可能导致记录和回放时可能执行不同的代码！请小心避免这种情况。
## `MouseEvent.relatedObject` 和 `FocusEvent.relatedObject` ##
这两个变量是显示对象的引用，而且还可能不在 Stage 上，因此无法序列化，不被支持。回放录象时，`relatedObject` 总是 `null` ， `isRelatedObjectInaccessible` 总是 `true`.
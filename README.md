# jl61.com
【游戏资源不完全】
此为热血精灵派的游戏资源文件，旨在为游戏关服后能留作怀念或（为大佬建立怀旧服）而收集的游戏数据文件
GitHub中的文件不完全
相对完全的游戏资源在<div style="text-align:center;">游戏文件： <a href="http://lanjiang.top:5244/1T/jl61.com.zip/" target="_blank">热血精灵派游戏资源</a></div>
目前游戏文件只包含服务器内可加载的精灵模型与地图等，精灵战斗画面尚未完全

有看见此游戏资源但游戏服务器并未完全关服的朋友，可以自行从游戏中获取资源：
工具：fiddler，游戏登录器；
在fiddler的自定义规则中
![image](https://user-images.githubusercontent.com/113574213/198909042-7c5c8c53-d575-46bd-ae7d-18c7d3d0e96c.png)
找到
![image](https://user-images.githubusercontent.com/113574213/198909090-cedaab85-00ff-4710-87a4-d0faf42050ed.png)
将原本的OnBeforeResponse函数：
 ```static function OnBeforeResponse(oSession: Session) {
        if (m_Hide304s && oSession.responseCode == 304) {
            oSession["ui-hide"] = "true";
        }
    }```
改为：
     ```static function OnBeforeResponse(oSession: Session) {
        if (m_Hide304s && oSession.responseCode == 304) {
            oSession["ui-hide"] = "true";
        }
                // iyzyi添加，swf文件自动保存
                oSession.utilDecodeResponse();
                if (oSession.oResponse.headers.ExistsAndContains("Content-Type", "application/x-shockwave-flash")) { 
                        var str = oSession.url;
                        var index = str.lastIndexOf("?")
                        if (index != -1){
                                str = str.substring(0,index);
                        }
                        oSession.SaveResponseBody("C:\\jl61.com\\" + str);
                }
                // iyzyi添加，swf文件自动保存
    }```  
上面脚本的作用是：当接收到响应response时，如果其Content-Type是application/x-shockwave-flash，则自动将其保存到文件夹c:\jl61.com中。

fiddler script是用js写的，大家可以自己按照自己的需求去修改。
之后打开游戏登录器，打开fiddler，加载游戏资源只需点击游戏场景即可。

文件夹内容格式应为：
*  jl61.com
   *  dll
      * module
      * 各种swf  
   *  resource
      *  attr
      *  item
      *  loginshow
      *  map
      *  moduleIU
      *  other
      *  panel
      *  pet
      *  regular
      *  rune
      *  shop
      *  skill
      *  title
      *  userbuff
      *  world
      *  各种swf
   *  version
      *  version加密文件.swf
   *  client.swf
*  webres.61.com
     *  common
   * css (这个不是资源文件，所以fd不会保存）  
<div style="text-align:center;">参考资料：<a href="https://www.52pojie.cn/thread-1468888-1-1.html" target="_blank">赛尔号：通信协议逆向与模拟&中间人攻击窃取登录凭证</a></div>

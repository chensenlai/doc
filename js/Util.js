var Util = {
    /**
     * 获取url中"?"符后的字串
     * let code = getRequestParam()["code"]
     *
     * @returns {Object}
     */
    getRequestParam : function() {
        var url = location.search;
        var theRequest = new Object();
        if (url.indexOf("?") != -1) {
            var str = url.substr(1);
            var strs = str.split("&");
            for(var i = 0; i < strs.length; i ++) {
                theRequest[strs[i].split("=")[0]]=unescape(strs[i].split("=")[1]);
            }
        }
        return theRequest;
    },

    /**
     * 微信JSAPI分享
     * config = {
     *     appId :
     *     timestamp :
     *     nonceStr :
     *     signature :
     *     logo :
     *     url : window.location.href
     *     title :
     *     desc :
     * }
     */
    wxjsapiShare : function(config) {
        if(!wx) {
            return;
        }
        var logo = config.logo;
        var url = config.url;
        var title = config.title;
        var desc = config.desc;
        wx.config({
            debug: false,
            appId: config.appId,
            timestamp: config.timestamp,
            nonceStr: config.nonceStr,
            signature: config.signature,
            jsApiList: [
                'onMenuShareTimeline',
                'onMenuShareAppMessage',
                'onMenuShareQQ',
                'onMenuShareWeibo',
                'onMenuShareQZone'
            ]
        });
        wx.error(function(res){});
        wx.ready(function () {
            share();
        });
        function share() {
            wx.onMenuShareTimeline({
                title: title,
                link: url,
                imgUrl: logo,
                success: function () {
                },
                cancel: function () {
                }
            });
            wx.onMenuShareAppMessage({
                title:title,
                desc: desc,
                link: url,
                imgUrl: logo,
                type: 'link',
                dataUrl: '',
                success: function () {},
                cancel: function () {}
            });
            wx.onMenuShareQQ({
                title: title,
                desc: desc,
                link: url,
                imgUrl: logo,
                success: function () {},
                cancel: function () {}
            });
            wx.onMenuShareWeibo({
                title: title,
                desc: desc,
                link: url,
                imgUrl: logo,
                success: function () {},
                cancel: function () {}
            });
            wx.onMenuShareQZone({
                title: title,
                desc: desc,
                link: url,
                imgUrl: logo,
                success: function () {},
                cancel: function () {}
            });
        }
    },

    /**
     * 跳转或打开APP
     * @param openUrl 打开APP自定义url
     * @param callback 是否打开APP回调, 入参 1-打开APP  2-没有打开APP
     */
    jumpOrDownload : function(openUrl, callback) {
        function checkOpen(cb){
            var _clickTime = +(new Date());
            function check(elsTime) {
                if ( elsTime > 3000 || document.hidden || document.webkitHidden) {
                    cb(1);
                } else {
                    cb(0);
                }
            }
            //启动间隔20ms运行的定时器，并检测累计消耗时间是否超过3000ms，超过则结束
            var _count = 0, intHandle;
            intHandle = setInterval(function(){
                _count++;
                var elsTime = +(new Date()) - _clickTime;
                if (_count>=100 || elsTime > 3000 ) {
                    clearInterval(intHandle);
                    check(elsTime);
                }
            }, 20);
        }

        //在iframe 中打开APP
        var ifr = document.createElement('iframe');
        ifr.src = openUrl;
        ifr.style.display = 'none';

        if (callback) {
            if (Util.isWechatBrowser()) {
                console.log("在微信浏览器");
                callback(0);
            }else{
                checkOpen(function(opened){
                    callback && callback(opened);
                });
            }
        }

        document.body.appendChild(ifr);
        setTimeout(function() {
            document.body.removeChild(ifr);
        }, 2000);
    },

    /**
     * 身份证上提取性别
     * @param idcard
     * @returns {number} 1-男 0-女
     */
    gender : function(idcard) {
        if (parseInt(idcard.slice(-2, -1)) % 2 == 1) {
            return 1;
        } else {
            return 0;
        }
    },

    /**
     * 身份证提取出生日期
     * @param idcard
     * @returns {string}
     */
    birthDate : function(idcard) {
        var birthday = "";
        if(idcard != null && idcard != ""){
            if(idcard.length == 15){
                birthday = "19"+idcard.slice(6,12);
            } else if(idcard.length == 18){
                birthday = idcard.slice(6,14);
            }
            birthday = birthday.replace(/(.{4})(.{2})/,"$1-$2-");
            //通过正则表达式来指定输出格式为:1990-01-01
        }
        return birthday;
    },

    isAppWebView : function(appWebView) {
        try{
            var ua = window.navigator.userAgent.toLowerCase();
            if(ua.indexOf(appWebView)>-1){
                return true;
            }
            return false;
        }catch (e) {
            console.error(e);
            return false;
        }
    },

    /**
     * 是否在android设备
     * @returns {boolean}
     */
    isAndroid : function() {
        try{
            var ua = window.navigator.userAgent.toLowerCase();
            if(ua.match(/android/ig)){
                return true;
            }
            return false;
        }catch (e) {
            console.error(e);
            return false;
        }
    },

    /**
     * 是否在IOS设备
     * @returns {boolean}
     */
    isIOS : function() {
        try{
            var ua = window.navigator.userAgent.toLowerCase();
            if(ua.match(/iphone|ipod|ipad/ig)){
                return true;
            }
            return false;
        }catch (e) {
            console.error(e);
            return false;
        }
    },

    /**
     * 是否在iphone设备
     * @returns {boolean}
     */
    isIphone : function() {
        try{
            var ua = window.navigator.userAgent.toLowerCase();
            if(ua.match(/iphone|ipod/ig)){
                return true;
            }
            return false;
        }catch (e) {
            console.error(e);
            return false;
        }
    },

    /**
     * 是否在ipad设备
     * @returns {boolean}
     */
    isIpad : function() {
        try{
            var ua = window.navigator.userAgent.toLowerCase();
            if(ua.match(/ipad/ig)){
                return true;
            }
            return false;
        }catch (e) {
            console.error(e);
            return false;
        }
    },

    /**
     * 判断是否在微信浏览器
     * @returns {boolean}
     */
    isWechatBrowser : function(){
        try{
            var ua = window.navigator.userAgent.toLowerCase();
            if(ua.match(/MicroMessenger/i) == 'micromessenger'){
                return true;
            }else{
                return false;
            }
        }catch (e) {
            console.error(e);
            return false;
        }
    },

    /**
     * 是否在支付宝公众号webview里面
     * @returns {boolean}
     */
    isAliBrowser : function(){
        try{
            var ua = window.navigator.userAgent.toLowerCase();
            if(ua.match(/aliapp/i) == 'aliapp'){
                return true;
            }else if(ua.match(/alipayclient/i) == 'alipayclient') {
                return true;
            }
            return false;
        }catch (e) {
            console.error(e);
            return false;
        }
    },

    /**
     * 判断是否在支付宝小程序
     * @returns {boolean}
     */
    isAliProgramBrowser : function(){
        try{
            if(window.my && window.my.tradePay) {
                return true;
            }
            return false;
        }catch (e) {
            console.error(e);
            return false;
        }
    },

    /**
     * 是否Iphone全面屏手机
     * @returns {Window | boolean}
     */
    isNewIpPhone : function() {
        return window
            && navigator.userAgent.indexOf('iPhone')>-1
            && window.screen.height >= 812 &&
            window.devicePixelRatio >= 2;
    }
};

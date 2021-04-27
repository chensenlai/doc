var Cnzz = {
   /**
     * 站长统计
     * 页面PV自动统计:
     *              var _czc = _czc || [];
     *              Cnzz.init();
     * 页面PV自定义统计:
     *              var _czc = _czc || [];
     *              Cnzz.autoPageview(_czc, false);
     *              Cnzz.init();
     *              Cnzz.trackPageView(_czc, "/index.html");
     *
     * 事件统计:
     *              var _czc = _czc || [];
     *              Cnzz.trackEvent(_czc, category, action, label);
     */
    init : function(cnzzId) {
        if(!document.getElementById("cnzz_stat_icon_"+cnzzId)) {
            try {
                var cnzz_protocol = (("https:" == document.location.protocol) ? "https://" : "http://");
                document.write(unescape("%3Cspan id='cnzz_stat_icon_"+cnzzId+"'%3E%3C/span%3E%3Cscript src='" + cnzz_protocol + "s4.cnzz.com/z_stat.php%3Fid%3D"+cnzzId+"' type='text/javascript'%3E%3C/script%3E"));
            } catch(e) {
                console.log(e);
            }
        }
        document.getElementById("cnzz_stat_icon_"+cnzzId).style.display="none";
    },

    /**
     * 设置是否自动PV统计
     * @param _czc
     * @param autopageview
     */
    autoPageview : function(_czc, autopageview) {
        _czc = _czc || [];
        _czc.push(["_setAutoPageview",autopageview]);
    },

    /**
     * 页面访问统计
     * @param _czc
     * @param content_url 访问页面
     * @param referer_url 来源页面
     */
    trackPageView : function(_czc, content_url, referer_url) {
        _czc = _czc || [];
        _czc.push(["_trackPageview",content_url,referer_url]);
    },

    /**
     * 事件统计
     * @param _czc
     * @param category 表示事件发生在谁身上
     * @param action 表示访客跟元素交互的行为动作
     * @param label 用于更详细的描述事件
     */
    trackEvent : function(_czc, category, action, label) {
        _czc = _czc || [];
        _czc.push(["_trackEvent",category,action,label]);
    }

}

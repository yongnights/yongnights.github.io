
<div class="copyright">{#
#}{% set current = date(Date.now(), "YYYY") %}{#
#}&copy; {% if theme.footer.since and theme.footer.since != current %}{{ theme.footer.since }} &mdash; {% endif %}{#
#}<span itemprop="copyrightYear">{{ current }}</span>

  <span class="with-love">
    <i class="fa fa-star"></i>
  </span>
  
  <span class="author" itemprop="copyrightHolder">{{ theme.footer.copyright || config.author }}</span>
  <br />
</div>

{% if theme.footer.powered %}
  <div class="powered-by">{#
  #}{{ __('footer.powered', '<a class="theme-link" target="_blank" href="https://hexo.io">Hexo</a>') }}{#
#}</div>
{% endif %}

{% if theme.footer.powered and theme.footer.theme.enable %}
  <span class="post-meta-divider">|</span>
{% endif %}

{% if theme.footer.theme.enable %}
  <div class="theme-info">{#
  #}{{ __('footer.theme') }} &mdash; {#
  #}<a class="theme-link" target="_blank" href="https://github.com/iissnan/hexo-theme-next">{#
    #}NexT.{{ theme.scheme }}{#
  #}</a>{% if theme.footer.theme.version %} v{{ theme.version }}{% endif %}{#
#}</div>
{% endif %}

{% if theme.footer.custom_text %}
  <div class="footer-custom">{#
  #}{{ theme.footer.custom_text }}{#
#}</div>
{% endif %}

<div>
  {% if theme.post_wordcount.totalcount %}

    <span class="post-meta-item-icon">
      <i class="fa fa-area-chart"></i>
    </span>
    {% if theme.post_wordcount.item_text %}
      <span class="post-meta-item-text">{{ __('post.totalcount') }} </span> 
    {% endif %}
    <span title="{{ __('post.totalcount') }}">{#
    #}: {{ totalcount(site, '0,0.0a') }} 字{#
  #}</span>
  {% endif %}
   <span class="post-meta-divider">||</span>
<!-- 在网页底部添加网站运行时间 --> 
<span id="timeDate">载入天数...</span><span id="times">载入时分秒...</span> 
<script> 
    var now = new Date(); 
    function createtime() { 
    var grt= new Date("03/01/2019 00:00:00");//此处修改你的建站时间或者网站上线时间,2019-03-01 
    now.setTime(now.getTime()+250); 
    days = (now - grt ) / 1000 / 60 / 60 / 24; 
    dnum = Math.floor(days); 
    hours = (now - grt ) / 1000 / 60 / 60 - (24 * dnum); 
    hnum = Math.floor(hours); 
    if(String(hnum).length ==1 ){hnum = "0" + hnum;} minutes = (now - grt ) / 1000 /60 - (24 * 60 * dnum) - (60 * hnum); 
    mnum = Math.floor(minutes); if(String(mnum).length ==1 ){mnum = "0" + mnum;} 
    seconds = (now - grt ) / 1000 - (24 * 60 * 60 * dnum) - (60 * 60 * hnum) - (60 * mnum); 
    snum = Math.round(seconds); 
    if(String(snum).length ==1 ){snum = "0" + snum;} 
    document.getElementById("timeDate").innerHTML = "博客已运行 "+dnum+" 天 "; 
    document.getElementById("times").innerHTML = hnum + " 小时 " + mnum + " 分钟 " + snum + " 秒"; } setInterval("createtime()",250); 
</script>
</div>

<div class="busuanzi-count">
    <span id="busuanzi_container_page_pv">
        <i class="fa fa-file-o"></i> 本文总阅读量<span id="busuanzi_value_page_pv"></span>次
    </span>
    <span class="post-meta-divider">||</span>
    <span id="busuanzi_container_site_uv">
        <i class="fa fa-user"></i> 本站访客数<span id="busuanzi_value_site_uv"></span>人次
    </span>
    <span class="post-meta-divider">||</span>
    <span id="busuanzi_container_site_pv">
        <i class="fa fa-eye"></i> 本站总访问量<span id="busuanzi_value_site_pv"></span>次
    </span>
</div>

<!-- 在网页底部添加当前时间 --> 
<div id="nowDate">
    <script type="text/javascript">
        window.onload = function () {
            var oDiv = document.getElementById('nowDate');
            function fnTimego() {
                var sNow = new Date();
                // 获取年份
                var iYear = sNow.getFullYear();
                // 获取月份，月份是从0到11，0表示一月，11表示十二月
                var iMonth = sNow.getMonth() + 1;
                var iDate = sNow.getDate();
                // 星期是从0到6,0表示星期天
                var iWeek = sNow.getDay();
                var iHour = sNow.getHours();
                var iMinute = sNow.getMinutes();
                var iSecond = sNow.getSeconds();
                var sTr = '当前时间是：' + iYear + '年' + iMonth + '月' + iDate + '日 ' + fnToweek(iWeek) + ' ' + fnTodou(iHour) + ':' + fnTodou(iMinute) + ':' + fnTodou(iSecond);
                oDiv.innerHTML = sTr;
            }
            // 刚开始调用一次，解决刚开始1秒钟空白的问题
            fnTimego();
            setInterval(fnTimego, 1000);
            function fnToweek(n) {

                if (n == 0) {
                    return '星期日';
                } else if (n == 1) {
                    return '星期一';
                } else if (n == 2) {
                    return '星期二';
                } else if (n == 3) {
                    return '星期三';
                } else if (n == 4) {
                    return '星期四';
                } else if (n == 5) {
                    return '星期五';
                } else {
                    return '星期六';
                }
            }
            function fnTodou(n) {
                if (n < 10) {
                    return '0' + n;
                } else {
                    return n;
                }
            }
        }
    </script>
</div>




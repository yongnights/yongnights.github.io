<div class="post-copyright">
  <li class="post-copyright-title">
    <strong>{{ __('本文标题') + __('symbol.colon') }}</strong>
    {{ page.title }}
  </li>
  <li class="post-copyright-author">
    <strong>{{ __('文章作者') + __('symbol.colon') }}</strong>
    {{ post.author | default(config.author) }}
  </li>
    <li class="post-copyright-author">
    <strong>{{ __('发布时间') + __('symbol.colon') }}</strong>
    {{ page.date.format("YYYY年MM月DD日 - HH:MM:SS") }}
  </li>
    <li class="post-copyright-author">
    <strong>{{ __('更新时间') + __('symbol.colon') }}</strong>
    {{ page.updated.format("YYYY年MM月DD日 - HH:MM:SS") }}
  </li>
  <li class="post-copyright-link">
    <strong>{{ __('本文链接') + __('symbol.colon') }}</strong>
    <a href="{{ url_for(page.path) }}" title="{{ page.title }}">{{ page.permalink }}</a>
    <span class="copy-path"  title="点击复制文章链接"><i class="fa fa-clipboard" data-clipboard-text="{{ page.permalink }}"  aria-label="复制成功！"></i></span>
  </li>
  <li class="post-copyright-license">
    <strong>{{ __('post.copyright.license_title') + __('symbol.colon') }} </strong>
    <i class="fa fa-creative-commons"></i> <a rel="license" href="https://creativecommons.org/licenses/by-nc-nd/4.0/" target="_blank" title="Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)">署名-非商业性使用-禁止演绎 4.0 国际</a> 转载请保留原文链接及作者。
  </li>
</div>

<script> 
    var clipboard = new Clipboard('.fa-clipboard');
	  $(".fa-clipboard").click(function(){
      clipboard.on('success', function(){
        swal({   
          title: "",   
          text: '复制成功',
          icon: "success", 
          showConfirmButton: true
          });
	    });
    });  
</script>

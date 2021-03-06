{% with pages=object.pages.all %}

<script type="text/javascript">

img_urlz = { {% for p in pages %}"#bimg{{ forloop.counter }}":"{%url download_page p.id %}",{% endfor %} '0': '0'};
mini_urlz = { {% for p in pages %}"mimg{{ forloop.counter }}":"{%url download_mpage p.id %}",{% endfor %} '0': '0'};

function load_image(id) {
	elem = '#bimg' + id;
	if ($(elem) != undefined && $(elem).attr('src') == '/static/blank.png')
		$(elem).attr('src', img_urlz[elem]);
}

function construct_b2m() {
	b2m = Array();
	// value of the first margin + pseudo page height
	boff = $('#pseudopage').height() + 15;
	
	$('.bigimg').each(function(idx) {
		b2m[idx] = boff + 5;
		boff = boff + 17 + $('#bpa' + (1 + idx)).height();
	});
}

function construct_m2p() {
	m2p = Array();
	boff = 0; // value of the first margin + pseudo page height
	
	$('.minimg').each(function(idx) {
		m2p[idx] = boff + 5;
		boff = boff + 47 + $('#mimg' + (1 + idx)).height();
	});
}

function construct_sizes() {
	sizes = Array();
	$('.bigimg').each(function(idx) {
		sizes[idx] = {'width': $('#bimg' + (1 + idx)).width(),
			      'height': $('#bimg' + (1 + idx)).height() };
	});
}

function pzoom() {
	$('.bigimg').each(function(idx) {
		$(this).width(sizes[idx].width * zoom /100);
		$(this).height(sizes[idx].height * zoom /100);
	});
	$('.bigpage').each(function(idx) {
		$(this).width($('#bimg' + (1 + idx)).width() + 2);
	});
	construct_b2m();
	$('#zv').val(Math.floor(zoom) + '%');
}

function refresh_mpage() {
	$('#mimg' + current_page).css('border', '1px #555 solid');
	for (current_page = b2m.length; current_page > 0; --current_page)
		if (b2m[current_page] < $('#pright').scrollTop())
			break;
	++current_page;
	$('#mimg' + current_page).css('border', '3px #5080ff solid');
	$('#pleft').scrollTop(m2p[current_page - 1]);
	if (backup_current_page != current_page) {
		// FIXME take account of page height!!
		var n = current_page - 2, t = current_page + 2;
		for (; n < t; ++n)
			load_image(n);
		backup_current_page = current_page;
	}
}

$(document).ready(function() {
  $(window).resize(function() {
  	$('#pages').height($(window).height() - 155);
  });
  $(window).resize();

  zoom = 100;
  current_page = 0;
  backup_current_page = 0;
  construct_sizes();
  construct_b2m();
  construct_m2p();
  refresh_mpage();

  $('.minimg').each(function(idx) {
  	$(this).click(function() {
  		$('#pright').scrollTop(b2m[idx] + 2);
  	});
  });

  $('#zp').click(function() {
  	if (zoom < 250)
  		zoom += 25;
	else
	  	zoom = zoom * 1.1;
  	pzoom();
  });

  $('#zm').click(function() {
  	if (zoom < 250)
  		zoom -= 25;
  	else
	  	zoom = zoom * 0.9;
  	if (zoom < 10)
  		zoom = 10; 
  	pzoom();
  });
  
  $('#zf').submit(function() {
  	zoom = $('#zv').val();
  	var i = zoom.indexOf("%");
  	if (i != -1)
  		zoom = zoom.substring(0, i);
  	zoom = Number(zoom)
  	if (zoom == NaN)
  		zoom = 100;
  	if (zoom < 10)
  		zoom = 10;
  	pzoom();
  });
  
  $('#pright').scroll(refresh_mpage);
  
{% if user.get_profile.moderate %}
  $('#edit_but').click(function(event) {
	overlay_reset();
	overlay_title("Edit Document");
	var form = document.createElement('form');
	form.id = 'edit_form';
	form.method = 'post';
	form.action = '{% url document_edit object.id %}';
	$(form).append('<input type="hidden" value="{{ csrf_token }} name="csrfmiddlewaretoken"/>');
	$(form).append('<table class="vtop">{{ eform.as_table|escapejs }}</table>');
	$(form).append('<center><input type="submit" value="edit" id="edit_button"/></center>');
	$('#overlay_content').html(form);
	overlay_show();
	overlay_refresh();
	$(form).submit(function() {
		Pload('edit_form', '{% url document_edit object.id %}', function(data) {
			$.getJSON('{% url document_desc object.id %}', function(doc) {
				$('#doc_name').html(doc.name);
				$('#doc_desc').html(doc.description);
			});
		});
		return false;
	});
  });
{% endif %}

  function load_min(i) {
  	$('#mimg'+i).attr('src', mini_urlz['mimg'+i]);
  	if (i < {{ object.size }})
  		setTimeout(function() { load_min(i+1); }, 10);
  }
  setTimeout(function () { load_min(1); }, 10);

});

</script>

<div id="pmenu">
  <form action="#" id="zf">
    <a class="back_but" href="{% url course_show object.refer.slug %}" 
       onclick="return Iload('{% url course_show object.refer.slug %}');"><< back to course</a>
    <a class="download_but" href="{% url download_file object.id %}">Download</a>
    <div style="float: left; margin-top: 2px"><img src="/static/l_plus.png" id="zp"/>&nbsp;&nbsp;&nbsp;<img src="/static/l_minus.png" id="zm"/></div>&nbsp;
    &nbsp;&nbsp;<input class="shadow" style="width: 50px" id="zv" value="100%"/>
    <input type="submit" style="display: none"/>&nbsp;&nbsp;&nbsp;
  </form>
</div>

<div id="pages">
    <div id="pleft"><center>
        {% for p in object.pages.all %}
            <p>page {{ forloop.counter }}</p>
            <img id="mimg{{ forloop.counter }}" class="page minimg"
                src="/static/blank.png" 
                width="118" height="{% widthratio p.height p.width 118 %}"><br>
        {% endfor %}</center>
    </div>
    <div id="pmiddle"></div>
    <div id="pright"><center>
		<div id="pseudopage">
		{% if user.get_profile.moderate %}
			<img style="margin-top: -1px; float: left; cursor: pointer"
				src="/static/edit.png" id="edit_but"/>
		{% endif %}
			<h1 id="doc_name">{{ object.name }}</h1>
			<p>Document uploaded by {{ object.owner.username }} on {{ object.date|date:"d/m/y H:i" }}<br>
			This document is classed in {{ object.points.full_category }}<br><br>
			<span id="doc_desc">{{ object.description }}</span></p>
		</div>

            {% for p in pages %}
                <div id="bpa{{ forloop.counter }}" class="bigpage" style="width: {{ p.width|add:2 }}">
                   <!-- <div class="pbutton" id="pbut{{ forloop.counter }}">
                    {% if p.threads.all %}
                      <span class="see_threads" id="pseethread{{ forloop.counter }}" 
                            onclick="list_thread({{ object.refer.id }}, {{ object.id }}, {{ p.id }});">C</span><br>
                    {% endif %}
                      <span class="add_comment"
                            onclick="">A</span>
                    </div>-->
                    
                    <img id="bimg{{ forloop.counter }}"
                        class="page bigimg" src="/static/blank.png" 
                        width="{{ p.width }}" height="{{ p.height }}">

                    <div class="comments">
                         <img style="float: left; margin-top: -8px" src="/static/com-left.png"/>
                         <div class="white" onclick="new_thread_box({{ object.refer.id }}, {{ object.id }}, {{ p.id }});">Add comment</div>
                         {% if p.threads.all %}
                         <img style="margin-bottom: -12px; margin-top: -8px;" src="/static/com-middle.png"/>
                         {% with c=p.threads.all|length %}
                         {% if c == 1 %}
                         <div class="white" onclick="list_thread({{ object.refer.id }}, {{ object.id }}, {{ p.id }});">Read the comment</div>
                         {% else %}
                         <div class="white" onclick="list_thread({{ object.refer.id }}, {{ object.id }}, {{ p.id }});">Read the {{ c }} comments</div>
                         {% endif %}
                         {% endwith %}
                         {% endif %}
                         <img style="float: right; margin-top: -8px" src="/static/com-right.png"/>
                    </div>
                </div>
            {% endfor %}
    </center></div>
</div>
{% endwith %}

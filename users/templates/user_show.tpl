<script type="text/javascript">

function join_course(slug) {
    $.get('/user/join/' + slug, function(data) {
        if (data == 'ok') 
            alert("ok");
    });
}

function add_course_box() {
    overlay_reset();
    overlay_title("Add course");
    overlay_show();
    
    $.getJSON('{% url courses_all %}', function(data) {
        var items = [];

        $.each(data, function(key, val) {
            S = val.fields.slug;
            items.push('<li><a href="/course/s/' + S + '">' + S + '</a> : ' + 
                val.fields.name + ' <a onclick="join_course(\'' + S + 
                '\');">join</a></li>');
        });

        $('#overlay_content').html($('<ul/>', {
            'class': 'course_list',
            html: items.join('')
        }));
        
        overlay_refresh();
    });
}
</script>

<p>welcome {{ user.username }}.</p>
<p><input type="button" onclick="add_course_box();" value="add course"/></p>


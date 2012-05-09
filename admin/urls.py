from django.conf.urls.defaults import patterns, url
from django.views.generic.simple import direct_to_template
from django.views.generic.list_detail import object_list
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User
from admin.views import catadd, catnew, catrm, course_add
from utils.json import json_list
from utils.decorators import AR
from courses.models import NewCourseForm
from documents.models import Document

urlpatterns = patterns('admin.views',
    url(r'^tree$', AR(login_required(direct_to_template)), 
        {'template': 'adm_tree.tpl',
         'extra_context': {'nform': NewCourseForm()}}, 
        name="category_tree"),

    url(r'^tree/catadd/(?P<category>[^/]+)/(?P<subcategory>[^/]+)$', 
        login_required(catadd), name="adm_tree_add"),

    url(r'^tree/catnew/(?P<category>[^/]+)/(?P<name>[^/]+)$', 
        login_required(catnew), name="adm_tree_new"),

    url(r'^tree/catrm/(?P<category>[^/]+)/(?P<parent>[^/]+)$',
        login_required(catrm), name="adm_tree_rm"),

    url(r'^tree/courseadd/(?P<category>[^/]+)/(?P<slug>[^/]+)$',
        login_required(course_add), name="adm_tree_c_add"),

    url(r'^users$', AR(login_required(object_list)), 
        {'template_name': 'adm_users.tpl',
         'queryset': User.objects.all()}, 
        name="admin_users"),

    url(r'^documents$', AR(login_required(object_list)), 
        {'template_name': 'adm_documents.tpl',
         'queryset': Document.objects.all()}, 
        name="admin_documents"),

    url(r'', AR(login_required(direct_to_template)), 
        {'template': 'admin.tpl'}, name="admin_index"),
)

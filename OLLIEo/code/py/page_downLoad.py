# -*- coding: utf-8 -*-
"""
Created on Sun Mar  5 19:49:35 2023

@author: OLLIEo
"""

#需求 下载前十页的图片
#https://sc.chinaz.com/tupian/qinglvtupian.html   1
#https://sc.chinaz.com/tupian/qinglvtupian_page.html
import urllib.request
from lxml import etree
def create_request(page):
    if (page==1):
        url='https://sc.chinaz.com/tupian/qinglvtupian.html '
    else:
        url='https://sc.chinaz.com/tupian/qinglvtupian_' + str(page) + '.html'
    #print(url)
    headers={
 'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36 Edg/110.0.1587.57'
 }       
    request=urllib.request.Request(url=url,headers=headers)
    return request 

def get_content(request):
    response=urllib.request.urlopen(request)
    content=response.read().decode('utf-8')
    return content

def down_load(content):
    tree=etree.HTML(content)
    name_list=tree.xpath('//div[@id="container"]//a/img/@alt')
    #一般设计图片的网站都会进行懒加载
    src_list=tree.xpath('//div[@id="container"]//a/img/@src2')
    print(type(name_list))
    print(len(name_list),len(src_list))
    
    for i in range (len(name_list)):
        name=name_list[i]
        src=src_list[i]
        url='https:' + src
        print(name,url)
        urllib.request.urlretrieve(url=url,filename='./folder_name/' + name + '.jpg')

if __name__=='__main__':
    start_page=int(input('请输入起始页： '))
    end_page=int(input('请输入结束页： '))
    for page in range(start_page,end_page+1):
        request=create_request(page)
        content=get_content(request)
        down_load(content)
'''
一、什么是懒加载？
懒加载就是延迟加载。针对多图片的页面，只有当该图片出现在页面视区中，再加载该图片。
可以防止页面一次性加载完所有的图片，用户等待时间长，影响用户体验。

二、如何实现懒加载
1.将页面中所有的src属性设置为空，并将src属性真正的值存放在自定义属性data-originnal（自定义属性以data-开头）。
2.为页面中的图片设置好大小，防止引起页面的回流，影响性能。
3.判断元素是否进入用户视野中。（利用元素的offsetTop属性和scrollTop、clientTop之间的关系判断），
若进入视野，则将data-originnal属性的值赋给图片的src属性。
4.滚动，重复判断元素是否进入视野。

'''
        
        
        
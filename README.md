# XMLParser
简单的XML数据解析

使用NSXMLParser  
```  
NSString *xmlString = @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
    <div class='test_class' href='www.xxxxx.com'>\
        <img href='www.test1.png'>\
            <name>img_test_1</name>\
        </img>\
        <img href='www.test2.png'>\
            <name>img_test_1</name>\
            <app>google app</app>\
            <version>v8.8</version>\
        image_content</img>\
    </div>";
    
NSDictionary *dictionary = [XMLParser dictionaryForXMLString:xmlString];  
```  
```  
解析结果
{
    div =     {
        class = "test_class";
        href = "www.xxxxx.com";
        img =         (
                        {
                href = "www.test1.png";
                name = "img_test_1";
            },
                        {
                app = "google app";
                href = "www.test2.png";
                "label_content" = "image_content";
                name = "img_test_1";
                version = "v8.8";
            }
        );
    };
}  
```

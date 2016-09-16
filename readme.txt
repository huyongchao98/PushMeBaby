将deviceToken填写，对应的SSL证书（可到苹果开发者网站下载）替换对应的aps_development.cer运行程序即可,需要查看
targets---build phases--copy bundle resources是否包含导入的证书，没有的话添加，否则
读取证书会失败,PushMeBaby 需要不间断的关闭了，再开，否则有可能连接自动断开，无法正确发送消息。

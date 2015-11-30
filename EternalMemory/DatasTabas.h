//
//  DatasTabas.h
//  EternalMemory
//
//  Created by Guibing Li on 13-5-26.
//  Copyright (c) 2013年 sun. All rights reserved.
//riji
/*
 "accessLevel": 0,
 "blogType": 1,
 "blogcount": 1,
 "createTime": 0,
 "deleteStatus": 0,
 "groupId": 0,
 "latestPhotoURL": "http://192.168.7.183:8080/blog/upload/2013060913060817111_thumb.jpg",
 "remark": "",
 "syncTime": 0,
 "title": "默认相册",
 "userId": "00faca31-d00c-11e2-8eb3-7c4d0e60b671"
 */

#ifndef EternalMemory_DatasTabas_h
#define EternalMemory_DatasTabas_h



#define DBVersion   @"CREATE TABLE if not exists 'DBVersion'('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,dbVersion integer)"

//图片分类列表
#warning audioPath, audioDuration, audioSize, audioURL, audioStatus syncStatus 增加四个字段
#define DiaryPictureClassification(UIDNAME) [NSString stringWithFormat:@"CREATE TABLE if not exists 'DiaryPictureClassification_%@'('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, accessLevel TEXT,blogType TEXT,blogcount TEXT default '0',createTime TEXT,deleteStatus BOOL,groupId TEXT,latestPhotoURL TEXT, remark TEXT,syncTime TEXT,latestPhotoPath Text,title TEXT,userId TEXT, audioPath TEXT, audioDuration integer, audioSize integer, audioURL TEXT, audioStatus integer, syncStatus integer, serverversion TEXT)",UIDNAME]
//消息表

#warning theOrder, photoWall, templatePath, templateUrl 增加四个字段
#define Message(UIDNAME) [NSString stringWithFormat:@"CREATE TABLE if not exists 'Message_%@'('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, blogId TEXT,blogType TEXT,summary TEXT,content TEXT,groupid TEXT,groupname TEXT,title TEXT, accessLevel TEXT,attachURL TEXT,thumbnail TEXT,paths TEXT,spaths TEXT, temp_paths TEXT, temp_spaths TEXT, serverVer TEXT,localVer TEXT,status TEXT status TEXT DEFAULT '1',deletestatus BOOL default 0,needSyn BOOL,needUpdate BOOL,needDownL BOOL,size TEXT,createTime TEXT,lastModifyTime TEXT,syncTime TEXT,remark TEXT,userId TEXT,audioPath TEXT, audioDuration integer, audioSize integer, audioURL TEXT, audioStatus integer, theOrder text, photoWall text, templatePath, text, templateUrl text)",UIDNAME]



//日记分组数据库表(duration fontsize isdefault status  the order tyoeface url voiceSize voiceURL 这几个字段暂时未添加到数据库表中)
#define DiaryGroups(UIDNAME)  [NSString stringWithFormat:@"CREATE TABLE if not exists 'DiaryGroups_%@'('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, accessLevel TEXT,blogType TEXT,blogcount TEXT default '0',createTime TEXT,deleteStatus BOOL,groupId TEXT, remark TEXT,syncTime TEXT,title TEXT,userId TEXT)",UIDNAME]

//日记内容数据库表 (clientId  url fontsize  typeface 这几个字段没有添加到数据库表中)
#define DiaryMessage(UIDNAME) [NSString stringWithFormat:@"CREATE TABLE if not exists 'DiaryMessage_%@'('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, blogId TEXT,blogType TEXT,summary TEXT,content TEXT,groupid TEXT,groupname TEXT,title TEXT, accessLevel TEXT, serverVer TEXT,localVer TEXT,status TEXT,deletestatus BOOL default 0,needSyn BOOL,needUpdate BOOL,needDownL BOOL,size TEXT,createTime TEXT,lastModifyTime TEXT,syncTime TEXT,remark TEXT,userId TEXT, theOrder text, versions TEXT)",UIDNAME]



#warning 新添加数据表， 应用更新时处理
#define AllLifeMemo(UIDNAME) [NSString stringWithFormat:@"CREATE TABLE if not exists 'AllLifeMemo_%@'('id' integer primary key autoincrement not null, blogId text, content text, status text, photoWall text, theOrder text, templateUrl text, templatePath text, photoUrl text, photoPath text, title text, userId text)",UIDNAME]

#define StyleList(UIDNAME)[NSString stringWithFormat:@"CREATE TABLE if not exists 'StyleList_%@'('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,sid INTEGER,zippath TEXT,zipname TEXT,thumbnail TEXT,bigimagepath TEXT,styleName TEXT,styleId INTEGER,typeName TEXT)",UIDNAME]
//#define StyleList(UIDNAME)[NSString stringWithFormat:@"CREATE TABLE if not exists 'StyleList_%@'('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,jsonStr TEXT)",UIDNAME]
#define StyleDownLoad(UIDNAME)[NSString stringWithFormat:@"CREATE TABLE if not exists 'StyleDownLoad_%@'('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,styleId INTEGER,isDownLoad INTEGER default 0)",UIDNAME]

#define MyFamily(UIDNAME)[NSString stringWithFormat:@"CREATE TABLE if not exists 'MyFamily_%@'('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,address text,associateAuthCode text,associateKey text,associateUserId text,associateValue text,associated integer,birthDate long long,birthDateStr text,birthWarned integer,deathDate text,deathDateStr text,deathWarned integer,motherId text,isDead integer,headPortrait text,directLine integer,eternalCode text,eternalnum text,intro text,kinRelation integer,level integer,memberId text,name text,nickName text,parentId text,partnerId text,sex integer,subTitle text,userId text)",UIDNAME]

#define ExceptionBug @"CREATE TABLE if not exists 'ExceptionBug'('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,content text,osversion text,appversion text,happentime text,devicemodel text,internet text)"

#endif

//
//  main.m
//  快速删除文件注释
//
//  Created by huangyipeng on 14-7-14.
//  Copyright (c) 2014年 hyp. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        NSString *path = @"/Users/hyp/开发/头文件/CoreBluetooh";
        
        // 取得所在文件夹的所有路径
        NSFileManager *fmgr = [NSFileManager defaultManager];
        NSArray *pathArray = [fmgr subpathsAtPath:path];
        
        [fmgr createDirectoryAtPath:[NSString stringWithFormat:@"%@/删除后",path] withIntermediateDirectories:YES attributes:nil error:nil];
        
        // 遍历所有路径，查找是否是.m .h .c结束的文件
        for (NSString *subPath in pathArray) {
            
            // 取出最后一个路径
            NSString *last = [subPath lastPathComponent];
            // 取出文件的扩展名
            NSString *extension = [last pathExtension];
            
            // 判断是否是.m .h .c文件
            if ([extension isEqualToString:@"m"] ||
                [extension isEqualToString:@"h"] ||
                [extension isEqualToString:@"c"] ) {
                // 取得全路径
                NSString *fullPath = [NSString stringWithFormat:@"%@/%@",path,subPath];
                // 获取文件内容
                NSString *contents = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:nil];
                // 对文件进行分割，取得了每一行的数据存入了数组中
                NSArray *contentArr = [contents componentsSeparatedByString:@"\n"];
                
                NSMutableArray *resultArray = [NSMutableArray array];
                for (__strong NSString *strTemp in contentArr) {
                    
                    // 去除头尾的空格
                    if (([strTemp hasPrefix:@"//"] || [strTemp hasPrefix:@"/*"])) {
                        strTemp = [strTemp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        [resultArray  addObject:strTemp];
                    } else {
                        [resultArray  addObject:strTemp];
                    }
                }
                
#pragma mark - 删除 /* */ 这种多行注释
                for (int i = 0; i < resultArray.count; i++) {
                    // 取出每一行文件内容
                    NSString *preContent = resultArray[i];
                    
                    // 如果是以/*开头，则遍历后面所有的数组找出 */
                    if ([preContent hasPrefix:@"/*"]) {
                        
                        // 遍历后面的内容，找出 */
                        for (int j = i; j < resultArray.count; j++) {
                            NSString *subContent = resultArray[j];
                            // 如果是以*/ 结尾，则证明找到了注释的行数，删除该行，退出循环
                            if ([subContent hasSuffix:@"*/"] || [subContent hasPrefix:@"*/"] ) {
                                // 删除所有的注释行
                                for(int k=i;k<=j;k++)
                                {
                                    [resultArray removeObjectAtIndex:i];
                                }
                                // 给i赋值为-1，进行一次++后回从头开始查找注释行
                                i = -1;
                                break;
                            }
                        }
                    }
                }
                
#pragma mark - 删除 // 这种单行注释
                for (int i = 0; i < resultArray.count; i++) {
                    NSString *tempContent = resultArray[i];
                    if ([tempContent hasPrefix:@"//"]) {
                        [resultArray removeObjectAtIndex:i];
                        i = -1;
                    }
                }
                
#pragma mark - 删除行内注释 //
                NSMutableArray *newArray = [NSMutableArray array];
                for (NSString *strTmp in resultArray) {
                    // 取出每一段注释的位置
                    NSRange range = [strTmp rangeOfString:@"//"];
                    // 判断注释是否为空
                    if (0 == range.length) {
                        // 注释为空，直接将该段写入到数组中
                        [newArray addObject:strTmp];
                    } else if (range.length) {
                        NSRange subRange = NSMakeRange(0, (range.location - 1));
                        NSString *temp = [strTmp substringWithRange:subRange];
                        [newArray addObject:temp];
                    }
                }
                resultArray = [NSMutableArray arrayWithArray:newArray];
                
                
                
                // 三次删除结束以后则删除了所有的注释，写入副本文件
                NSString *fullPathWrite = [NSString stringWithFormat:@"%@/删除后/%@",path,subPath];
                NSMutableString *fullContent = [NSMutableString string];
                for (NSString *str in resultArray) {
                    [fullContent appendString:str];
                    [fullContent appendString:@"\n"];
                }
                [fullContent writeToFile:fullPathWrite atomically:YES encoding:NSUTF8StringEncoding error:nil];
                
                
            }
        }
    }
    return 0;
}


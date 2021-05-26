//
//  MetaCatalog.swift
//  
//
//  Created by Hervé LEMAI on 26/05/2021.
//

import Foundation

struct Meta {
    var name:String
    var descDict:[String:String]=[:]
}

struct Table {
    var tableDesc:Meta
    var metaDict : [String : Meta] = [:]
}

typealias MetaCatalog = [String : Table]

extension MetaCatalog {
    
    /// build from xml produce by exif tool
    static func buildfrom(xmlDocument:XMLDocument) -> MetaCatalog {
        var catalog = MetaCatalog()
        
        if let rootNode = xmlDocument.rootDocument?.child(at: 1) {
            if let children = rootNode.children {
                for child in children {
                    //<table name='AFCP::Main' g0='AFCP' g1='AFCP' g2='Other'>
                    if child.name != "table" {
                        continue
                    }
                    let groupname = (child as? XMLElement)?.attribute(forName: "name")?.stringValue ?? "Value"
                    var tableGroup : Table
                    
                    if catalog[groupname] == nil {
                        tableGroup = Table(tableDesc:Meta(name:groupname))
                    } else {
                        tableGroup = catalog[groupname]!
                    }
                    if let childrenTable = child.children {
                        for descOrTag in childrenTable {
                            if descOrTag.name == "desc" {
                                //<desc lang='en'>Comment Time</desc>
                                let lang = (descOrTag as? XMLElement)?.attribute(forName: "lang")?.stringValue ?? "en"
                                let desc = descOrTag.stringValue ?? ""
                                tableGroup.tableDesc.descDict[lang] = desc
                            }
                            if descOrTag.name == "tag" {
                                // <tag id='0' name='CommentTime' type='?' writable='false' g2='Time'>
                                if let tagname = (descOrTag as? XMLElement)?.attribute(forName: "name")?.stringValue {
                                    if let tagdescTable = descOrTag.children {
                                        for tagdesc in tagdescTable {
                                            if tagdesc.name == "desc" {
                                                //<desc lang='en'>Comment Time</desc>
                                                let lang = (tagdesc as? XMLElement)?.attribute(forName: "lang")?.stringValue ?? "en"
                                                let desc = tagdesc.stringValue ?? ""
                                                if tableGroup.metaDict[tagname] == nil {
                                                    tableGroup.metaDict[tagname]=Meta(name:tagname)
                                                }
                                                tableGroup.metaDict[tagname]?.descDict[lang]=desc
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    catalog[groupname] = tableGroup
                }
            }
        }
        return catalog
    }
    
    var flattenDic : [String : Meta] {
        get {
            var flattened : [String:Meta] = [:]
            self.forEach({ _,value in
                flattened.merge(value.metaDict, uniquingKeysWith: { (_, new) in new })
            })
            return flattened
        }
    }
}

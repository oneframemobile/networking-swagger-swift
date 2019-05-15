import json
import requests
import os
import urllib2
import json


class SwaggerFunctionParam(object):

    name = ""
    paramType = ""
    required = ""
    dataType = ""
    requestModel = ""

    # The class "constructor" - It's actually an initializer
    def __init__(self, name, paramType, required, dataType, requestModel):
        self.name = name
        self.paramType = paramType
        self.required = required
        self.dataType = dataType
        self.requestModel = requestModel


def make_SwaggerFunctionParam(_name, _paramType, required, _dataType, _requestModel):
    func = SwaggerFunctionParam(
        _name, _paramType, required, _dataType, _requestModel)
    return func


class SwaggerFunction(object):
    path = ""
    funcName = ""
    httpMethod = ""
    requestContentTypes = []
    responseContentTypes = []
    securityParams = []
    parameters = []
    resultType = ""
    resultModel = ""
    postBodyParam = ""

    requestFormula = ""
    # new
    # if have body
    bodyFormula = ""
    # if have path
    pathFormula = ""
    # if have query
    queryFormula = ""
    # function body param
    funcInlineParam = ""

    #  it's doesn't use now like bodyformula
    headerFormula = ""

    # The class "constructor" - It's actually an initializer

    formDataFormula = ""

    def __init__(self, _path):
        self.funcName = ""
        self.httpMethod = ""
        self.requestContentTypes = []
        self.responseContentTypes = []
        self.securityParams = []
        self.parameters = []
        self.resultType = ""
        self.resultModel = ""
        self.path = _path


def clear():
    path = ""


def make_SwaggerFunction(_path):
    func = SwaggerFunction(_path)
    return func

# primitive typeları swifte uygun hale çevrilir geri kalanlar direk basılır


def swift_TypeConverter(val):
    if val == "string" or val == "" or val == "file":
        return "String"
    elif val == "integer":
        return "Int"
    elif val == "array":
        return "[]"
    else:
        return val


def func_definitionTypeSplit(val):
    # need model name so use split definition path
    _definitionTypeSplit = val.split("/")
    definitionTypeUnWrapped = _definitionTypeSplit[len(
        _definitionTypeSplit)-1]
    return definitionTypeUnWrapped


def arrayConverter(val):
    # any model or primitive type convert array synax.
    return "["+swift_TypeConverter(val)+"]"


webPath = 'https://firebasestorage.googleapis.com/v0/b/swaggercodegen.appspot.com/o/oneframeapi.json?alt=media&token=616f331e-733f-4f2c-b63d-64d77f238e73'
# 'http://178.211.54.214:5000/swagger/v1/swagger.json'
# swagger-codegen generate -i http://petstore.swagger.io/v2/swagger.json -l swift4
try:
    '''
    result = json.load(urllib2.urlopen(webPath))
    for path in result["paths"]:
        pprint(result["paths"][path])
    '''
    resp = urllib2.urlopen(webPath)
    dataString = resp.read().decode('utf-8')
    jsonData = json.loads(dataString)
    functions = []
    # pprint(json(jsonData["paths"]))
    for path in jsonData["paths"]:
        print(path)
        for httpType in jsonData["paths"][path]:

            func = make_SwaggerFunction(str(path))
            func.httpMethod = str(httpType)
            func.funcName = str(
                jsonData["paths"][path][httpType]["operationId"])
            # request content type var mi?
            if jsonData["paths"][path][httpType].has_key('consumes'):
                if len(jsonData["paths"][path][httpType]["consumes"]) > 0:
                    for requestContentType in jsonData["paths"][path][httpType]["consumes"]:
                        func.requestContentTypes.append(
                            str(requestContentType))
            # response content type var mi?
            if len(jsonData["paths"][path][httpType]["produces"]) > 0:
                for responseContentType in jsonData["paths"][path][httpType]["produces"]:
                    func.requestContentTypes.append(str(responseContentType))
            # paramaters varmi ?
            # if i have paramaters but could paramaters is empty for add len conrol.
            if str(jsonData["paths"][path][httpType].get("parameters")) != 'None' and len(jsonData["paths"][path][httpType].get("parameters")) > 0:
                for parameters in jsonData["paths"][path][httpType]["parameters"]:
                    name = str(parameters["name"])
                    paramType = str(parameters["in"])
                    required = str(parameters["required"])
                    dataType = ""
                    requestModel = ""

                    if func.funcName == "RemoveClaimFromRole":
                        print "oke"

                    # if we have schema property will use type and
                    if str(parameters.get("schema")) != 'None':
                        if str(parameters["schema"].get("type")) != 'None':
                            dataType = str(parameters["schema"].get("type")) == "array" and str(
                                parameters["schema"]["type"]) or "String"
                        else:
                            dataType = "String"
                        if str(parameters.get("schema").get("items")) != 'None':
                            requestModel = func_definitionTypeSplit(
                                str(parameters.get("schema").get("items").get("$ref")))
                            if str(parameters.get("schema").get("type")) != "None":
                                requestModel = str(parameters.get("schema").get(
                                    "type")) == "array" and arrayConverter(requestModel) or requestModel
                        else:
                            if str(parameters.get("schema").get("$ref")) != 'None':
                                requestModel = func_definitionTypeSplit(
                                    str(parameters.get("schema").get("$ref")))
                            else:
                                requestModel = "String"

                    else:
                        dataType = swift_TypeConverter(str(parameters["type"]))
                        if str(parameters.get("items")) != 'None':
                            requestModel = arrayConverter(
                                str(parameters["items"].get("type")))
                        else:
                            requestModel = dataType
                    if paramType == "body":
                        func.postBodyParam = name
                        func.bodyFormula += len(func.bodyFormula) > 0 and (
                            ","+name + " : " + requestModel) or name + " : " + requestModel
                    elif paramType == "formData":
                        # len control so check formdata have any items
                        func.formDataFormula += len(func.formDataFormula) > 0 and (
                            ", \""+name+"\"" + " : " + "\"\("+name+")") or "\""+name+"\"" + " : " + "\"\("+name+")"
                    elif paramType == "query":
                        # if have already added query
                        if "?" in func.queryFormula:
                            func.queryFormula += "&"+name+"=\("+name+")"
                        else:
                            # first add query at url
                            func.queryFormula = func.path + \
                                "?"+name+"=\("+name+")"
                    elif paramType == "path":
                        # Fix path double index.
                        if func.pathFormula == "":
                            func.pathFormula = func.path.replace(
                                "{"+name+"}", ("\("+name+")"))
                        else:
                            func.pathFormula = func.pathFormula.replace(
                                "{"+name+"}", ("\("+name+")"))
                        # is have " character ?
                        func.pathFormula = func.pathFormula[0] == "\"" and func.pathFormula or "\"" + \
                            func.pathFormula+"\""

                    elif paramType == "header":
                        func.headerFormula += len(func.bodyFormula) > 0 and (
                            ","+name + " : " + requestModel) or name + " : " + requestModel
                    else:
                        func.pathFormula = "\""+func.pathFormula+"\""
                    if name != "" and paramType != "header":
                        if func.funcInlineParam == "":
                            func.funcInlineParam = name + ": " + requestModel
                        else:
                            func.funcInlineParam += ", " + name + ": " + requestModel
                        func.bodyFormula = name
                    func.parameters.append(make_SwaggerFunctionParam(
                        name, paramType, required, dataType, requestModel))

                # last character add ,
                if func.funcInlineParam != "":
                    func.funcInlineParam += ", "
                    # swift için çift tırnaklı hale getirme
                if func.queryFormula != "":
                    func.queryFormula = "\""+func.queryFormula+"\""
                if func.formDataFormula != "":
                    # formdata formulayı array olarak parse etmek için
                    func.formDataFormula = "[" + func.formDataFormula + "]"
                    func.bodyFormula = ""
            else:
                # herhangi bir istek yoksa direk path basılır
                func.pathFormula = "\""+func.path+"\""
            # response model type var mi?
            if len(jsonData["paths"][path][httpType]["responses"]) > 0:
                if str(jsonData["paths"][path][httpType]["responses"].get("200")) != 'None':
                    if str(jsonData["paths"][path][httpType]["responses"]["200"].get("schema")) != 'None':
                        if str(jsonData["paths"][path][httpType]["responses"]["200"].get("schema").get("$ref")) != 'None':
                            definitionTypeSplit = str(jsonData["paths"][path][httpType]["responses"].get(
                                "200").get("schema").get("$ref")).split("/")
                            definitionTypeUnWrapped = definitionTypeSplit[len(
                                definitionTypeSplit)-1]
                            func.resultModel = str(definitionTypeUnWrapped).replace(
                                "[", "").replace("]", "")
                            # TODO i think this trash. because it's sub child have ref param this means ı'm object.
                            if "List" not in definitionTypeUnWrapped:
                                func.resultType = "String"
                            else:
                                func.resultType = "List"
                        else:
                            schema = jsonData["paths"][path][httpType]["responses"]["200"].get(
                                "schema")
                            if str(schema.get("$items")) != 'None':
                                func.resultModel = func_definitionTypeSplit(
                                    schema.get("$items").get("$ref"))
                            else:
                                func.resultModel = str(schema.get(
                                    "$ref")) != 'None' and func_definitionTypeSplit(schema.get("$ref")) or "String"
                            if str(schema.get("type")) != 'None':
                                func.resultType = str(schema.get(
                                    "type")) == "object" and "String" or arrayConverter(str(schema.get("type")))
                            else:
                                func.resultType = "String"
            # swift formatına uygun model çevirisi
            func.resultModel = swift_TypeConverter(func.resultModel)
            func.bodyFormula = "\"\""
            functions.append(func)
        # pprint(func.funcName, func.httpMethod)
        # for requestContentTypes in jsonData["paths"][path][httpType]["consumes"]):
        #       pprint(requestContentTypes)
        #  break
        #    break

    print(len(functions))

# with open(last.strip(), 'wb') as fl:
    # fl.write(resp.read())
except urllib2.HTTPError as e:
    print('HTTPError = ' + str(e.code))
except urllib2.URLError as e:
    print('URLError = ' + str(e.reason))
except Exception as e:
    print('generic exception: ' + str(e))

import json
import requests
import os
import urllib2

from pprint import pprint


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

    # The class "constructor" - It's actually an initializer
    def __init__(self, _path):
        self.path = _path


def make_SwaggerFunction(_path):
    func = SwaggerFunction(_path)
    return func


def swift_TypeConverter(val):
    if val == "string":
        return "String"
    elif val == "integer":
        return "Int"
    elif val == "array":
        return "[]"


def definitionTypeSplit(val):
    _definitionTypeSplit = val.split("/")
    definitionTypeUnWrapped = _definitionTypeSplit[len(
        _definitionTypeSplit)-1]

    return str(definitionTypeUnWrapped).replace(
        "[", "").replace("]", "")


webPath = 'http://petstore.swagger.io/v2/swagger.json'
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

        for httpType in jsonData["paths"][path]:
            func = make_SwaggerFunction(str(path))
            func.httpMethod = str(httpType)
            func.funcName = str(
                jsonData["paths"][path][httpType]["operationId"])
            # request content type var mi?
            if jsonData["paths"][path][httpType].has_key('consumes'):
                if len(jsonData["paths"][path][httpType]["consumes"]) > 0:
                    for requestContentType in jsonData["paths"][path][httpType]["consumes"]:
                        func.requestContentTypes.append(requestContentType)
            # response content type var mi?
            if len(jsonData["paths"][path][httpType]["produces"]) > 0:
                for responseContentType in jsonData["paths"][path][httpType]["produces"]:
                    func.requestContentTypes.append(responseContentType)
            # paramaters varmi ?
            if jsonData["paths"][path][httpType].get("parameters") != 'None':
                for parameters in jsonData["paths"][path][httpType]["parameters"]:
                    name = str(parameters["name"])
                    paramType = str(parameters["in"])
                    required = str(parameters["required"])
                    dataType = ""
                    requestModel = ""
                    if parameters.get("schema") != 'None':
                        if parameters["schema"].get("type") != 'None':
                            dataType = str(parameters["schema"]["type"])
                        else:
                            dataType = "Object"
                        requestModel = definitionTypeSplit(str(parameters.get("schema")
                                                               .get("items").get("$ref")))
                    else:
                        dataType = swift_TypeConverter(str(parameters["type"]))
                        if parameters.get("items") != 'None':
                            pass
                        else:
                            pass

            func.parameters.append(make_SwaggerFunctionParam(
                name, paramType, required, dataType, requestModel))

            # response model type var mi?
            if len(jsonData["paths"][path][httpType]["responses"]) > 0:
                if str(jsonData["paths"][path][httpType]["responses"].get("200")) != 'None':
                    if jsonData["paths"][path][httpType]["responses"]["200"].get("schema") != 'None':
                        if jsonData["paths"][path][httpType]["responses"]["200"].get("schema").get("$ref") != 'None':
                            definitionTypeSplit = str(jsonData["paths"][path][httpType]["responses"].get(
                                "200").get("schema").get("$ref")).split("/")
                            definitionTypeUnWrapped = definitionTypeSplit[len(
                                definitionTypeSplit)-1]
                            func.resultModel = str(definitionTypeUnWrapped).replace(
                                "[", "").replace("]", "")
                            if "List" not in definitionTypeUnWrapped:
                                func.resultType = "Object"
                            else:
                                func.resultType = "List"

            functions.append(func)

            #pprint(func.funcName, func.httpMethod)
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

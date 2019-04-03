#! /bin/sh
""":"
exec python $0 ${1+"$@"}
"""
# import requests
import os
import sys
import re
import urllib2
import ssl
import shutil
import json


# 1.0.0
# networking-swagger-java -url -package -serviceName -resultJsonKey
# swagger json -parser classes

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
    resultModel = "String"

    # if have body
    bodyFormula = ""
    # if have path
    pathFormula = ""
    # if have query
    queryFormula = ""
    # and ???????
    funcInlineParam = ""

    headerFormula = ""

    formDataFormula = ""

    # The class "constructor" - It's actually an initializer

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
    _definitionTypeSplit = val.split("/")
    definitionTypeUnWrapped = _definitionTypeSplit[len(
        _definitionTypeSplit)-1]

    return definitionTypeUnWrapped
    # return str(definitionTypeUnWrapped).replace(
    #     "[", "").replace("]", "")


def arrayConverter(val):
    return "["+swift_TypeConverter(val)+"]"


def getSwaggerFunctionInfo(swaggerWebUrl):
    functions = []
    # webPath = 'http://petstore.swagger.io/v2/swagger.json'
    # 'http://178.211.54.214:5000/swagger/v1/swagger.json'
    # swagger-codegen generate -i http://petstore.swagger.io/v2/swagger.json -l swift4
    try:
        '''
        result = json.load(urllib2.urlopen(webPath))
        for path in result["paths"]:
            pprint(result["paths"][path])
        '''
        resp = urllib2.urlopen(swaggerWebUrl)
        dataString = resp.read().decode('utf-8')
        jsonData = json.loads(dataString)

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
                        func.requestContentTypes.append(
                            str(responseContentType))
                # paramaters varmi ?
                if str(jsonData["paths"][path][httpType].get("parameters")) != 'None' and len(jsonData["paths"][path][httpType].get("parameters")) > 0:
                    for parameters in jsonData["paths"][path][httpType]["parameters"]:
                        name = str(parameters["name"])
                        paramType = str(parameters["in"])
                        required = str(parameters["required"])
                        dataType = ""
                        requestModel = ""
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
                            dataType = swift_TypeConverter(
                                str(parameters["type"]))
                            # TODO 1. array ?
                            if str(parameters.get("items")) != 'None':
                                requestModel = arrayConverter(
                                    str(parameters["items"].get("type")))
                            else:
                                requestModel = dataType
                        if paramType == "body":
                            func.bodyFormula += len(func.bodyFormula) > 0 and (
                                ","+name + " : " + requestModel) or name + " : " + requestModel
                        elif paramType == "formData":
                            func.formDataFormula += len(func.formDataFormula) > 0 and (
                                ", \""+name+"\"" + " : " + "\"\("+name+")\"") or "\""+name+"\"" + " : " + "\"\("+name+")\""
                        elif paramType == "query":
                            if "?" in func.queryFormula:
                                func.queryFormula += "&"+name+"=\("+name+")"
                            else:
                                func.queryFormula = func.path + \
                                    "?"+name+"=\("+name+")"
                        elif paramType == "path":
                            func.pathFormula = func.path.replace(
                                "{"+name+"}", ("\("+name+")"))
                            func.pathFormula = "\""+func.pathFormula+"\""
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

                    if func.funcInlineParam != "":
                        func.funcInlineParam += ", "
                    if func.queryFormula != "":
                        func.queryFormula = "\""+func.queryFormula+"\""
                    if func.formDataFormula != "":
                        func.formDataFormula = "[" + func.formDataFormula + "]"
                        func.bodyFormula = ""

                else:
                    func.pathFormula = "\""+func.path+"\""
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
                                # TODO i think this trash. because it's sub child have ref param this means i'm object.
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
                func.resultModel = swift_TypeConverter(func.resultModel)
                functions.append(func)
            # pprint(func.funcName, func.httpMethod)
            # for requestContentTypes in jsonData["paths"][path][httpType]["consumes"]):
            #       pprint(requestContentTypes)
            #  break
            #    break
        # print(len(functions))
        return functions
    # with open(last.strip(), 'wb') as fl:
        # fl.write(resp.read())
    except urllib2.HTTPError as e:
        print('HTTPError = ' + str(e.code))
    except urllib2.URLError as e:
        print('URLError = ' + str(e.reason))
    except Exception as e:
        print('generic exception: ' + str(e))

# end swagger json -parser classes


def constant(f):
    def fset(self, value):
        raise TypeError

    def fget(self):
        return f()
    return property(fget, fset)


class _CodeLine(object):
    @constant
    def NEWLINE():
        return "\n"

    @constant
    def SPACE_AFTER():
        return "    "

    @constant
    def SLASH():
        return "/"

    @constant
    def DOT():
        return "."


class _DevelopmentEnvoirment(object):
    @constant
    def LOCAL():
        return "LOCAL"

    @constant
    def ONLINE():
        return "ONLINE"


class _MessageType(object):
    @constant
    def INFO():
        return "INFO"

    @constant
    def ERROR():
        return "ERROR"

    @constant
    def SUCCESS():
        return "SUCCESS"


# MESSAGE INIT
MESSAGE = _MessageType()
DEV_ENV = _DevelopmentEnvoirment()
CODING = _CodeLine()


def showErrorMessages(messageType, message):
    if intern(MESSAGE.ERROR) is intern(messageType):
        print ("\x1b[6;30;41m" + message + "\x1b[0m")
    elif intern(MESSAGE.SUCCESS) is intern(messageType):
        print ("\x1b[6;30;42m" + message + "\x1b[0m")
    elif intern(MESSAGE.INFO) is intern(messageType):
        print ("\x1b[7;37;40m" + message + "\x1b[0m")


param_url = ""
param_package = "Networking"
param_serviceName = ""
swagger_root_http_url = ""
SWIFT = ".swift"
MODULES = "networking"
MODELS = "models"
SWIFT_ROOT_PATH = "/networking-swagger"
JAVA_ANDROID_UNIT_TEST_ROOT_PATH = "/app/src/androidTest/java"
package_path = ""
NETWORKNG_SWAGGER_MANAGER_TEMPLATE = "Networking_swaggger_manager_template"
# FOR UNIT Test
NETWORKNG_SWAGGER_UNIT_TEST_TEMPLATE = "Networking_swagger_unit_test_class_template"
IS_ENABLE_UNIT_TEST_GENERATE = False
manager_filename = "ServiceManager.swift"
unit_test_filename = "NetworkingInstrumentedTest.java"
manager_file_content = ""
unit_test_file_content = ""

SWAGGER_CLIENT_FILEPATH = "SwaggerClient/Classes/Swaggers/Models/"
SWAGGER_CLIENT_ROOT_PATH = "SwaggerClient"

last_request_cache_key = ""
last_request_cache_content = ""


# CHILD
CHILD_MANAGER_IMPORT_PACKAGE_TEMPLATE = "Networking_swagger_import_package_inner_template"
CHILD_MANAGER_ADD_HEADER_TEMPLATE = "Networking_swagger_add_header_inner_template"
CHILD_MANAGER_GET_FUNC_TEMPLATE = "Networking_swagger_managerclass_request_func_get_child_inner_template"
CHILD_MANAGER_GET_FUNC_NO_SEMICOLON_TEMPLATE = "Networking_swagger_managerclass_request_func_get_no_semicolon_child_inner_template"
CHILD_MANAGER_POST_FUNC_TEMPLATE = "Networking_swagger_managerclass_request_func_post_child_inner_template"
CHILD_MANAGER_POST_FUNC_NO_SEMICOLON_TEMPLATE = "Networking_swagger_managerclass_request_func_post_no_semicolon_child_inner_template"
CHILD_MANAGER_IMPORT_PACKAGE_TEMPLATE = "Networking_swagger_import_package_inner_template"
CHILD_UNIT_TEST_GET_FUNC_TEMPLATE = "Networking_swagger_unit_test_request_func_get_template"
CHILD_UNIT_TEST_POST_FUNC_TEMPLATE = "Networking_swagger_unit_test_request_func_post_template"

CHILD_MANAGER_PUT_FUNC_TEMPLATE = "Networking_swagger_managerclass_request_func_put_child_inner_template"
CHILD_MANAGER_DELETE_FUNC_TEMPLATE = "Networking_swagger_managerclass_request_func_delete_child_inner_template"


TEMPLATE_FOLDER = "template/"
ONLINE_FOLDER = "https://raw.githubusercontent.com/oneframemobile/networking-swagger-swift/master/template"
parent_module = ''
sub_module = ''

root_path = ''
unit_test_root_path = ''
manager_file_path = ''
unit_test_file_path = ''

sub_module_type = '-s'
# folders = [WIREFRAME, INTERACTOR, VIEW ,PRESENTER, PROTOCOLS ]
# CURRENT_DEV_ENV LOCAL OR ONLINE(Github)
# CURRENT_DEV_ENV = DEV_ENV.ONLINE
CURRENT_DEV_ENV = DEV_ENV.LOCAL
SWIFT = ".swift"
model_package = "//{{model_package}}"
request_func = "//{{request_func}}"
unit_test_func = "//{{unit_test_func}}"


def initVariables():
    global CHILD_UNIT_TEST_POST_FUNC_TEMPLATE, CHILD_UNIT_TEST_GET_FUNC_TEMPLATE, NETWORKNG_SWAGGER_UNIT_TEST_TEMPLATE, IS_ENABLE_UNIT_TEST_GENERATE, replacement, child_replacement, last_request_cache_key, last_request_cache_content, NETWORKNG_SWAGGER_MANAGER_TEMPLATE, CHILD_MANAGER_ADD_HEADER_TEMPLATE, CHILD_MANAGER_GET_FUNC_TEMPLATE, CHILD_MANAGER_GET_FUNC_NO_SEMICOLON_TEMPLATE, CHILD_MANAGER_POST_FUNC_TEMPLATE, CHILD_MANAGER_POST_FUNC_NO_SEMICOLON_TEMPLATE, CHILD_MANAGER_IMPORT_PACKAGE_TEMPLATE, swagger_root_http_url,CHILD_MANAGER_PUT_FUNC_TEMPLATE,CHILD_MANAGER_DELETE_FUNC_TEMPLATE
    if intern(DEV_ENV.ONLINE) is intern(CURRENT_DEV_ENV):
        NETWORKNG_SWAGGER_MANAGER_TEMPLATE = ONLINE_FOLDER + \
            NETWORKNG_SWAGGER_MANAGER_TEMPLATE
        CHILD_MANAGER_ADD_HEADER_TEMPLATE = ONLINE_FOLDER + \
            CHILD_MANAGER_ADD_HEADER_TEMPLATE
        CHILD_MANAGER_GET_FUNC_TEMPLATE = ONLINE_FOLDER + CHILD_MANAGER_GET_FUNC_TEMPLATE
        CHILD_MANAGER_GET_FUNC_NO_SEMICOLON_TEMPLATE = ONLINE_FOLDER + \
            CHILD_MANAGER_GET_FUNC_NO_SEMICOLON_TEMPLATE
        CHILD_MANAGER_POST_FUNC_TEMPLATE = ONLINE_FOLDER + CHILD_MANAGER_POST_FUNC_TEMPLATE
        CHILD_MANAGER_PUT_FUNC_TEMPLATE = ONLINE_FOLDER + CHILD_MANAGER_PUT_FUNC_TEMPLATE
        CHILD_MANAGER_DELETE_FUNC_TEMPLATE = ONLINE_FOLDER + CHILD_MANAGER_DELETE_FUNC_TEMPLATE

        CHILD_MANAGER_POST_FUNC_NO_SEMICOLON_TEMPLATE = ONLINE_FOLDER + \
            CHILD_MANAGER_POST_FUNC_NO_SEMICOLON_TEMPLATE
        CHILD_MANAGER_IMPORT_PACKAGE_TEMPLATE = ONLINE_FOLDER + \
            CHILD_MANAGER_IMPORT_PACKAGE_TEMPLATE
        NETWORKNG_SWAGGER_UNIT_TEST_TEMPLATE = ONLINE_FOLDER + \
            NETWORKNG_SWAGGER_UNIT_TEST_TEMPLATE
        CHILD_UNIT_TEST_GET_FUNC_TEMPLATE = ONLINE_FOLDER + \
            CHILD_UNIT_TEST_GET_FUNC_TEMPLATE
        CHILD_UNIT_TEST_POST_FUNC_TEMPLATE = ONLINE_FOLDER + \
            CHILD_UNIT_TEST_POST_FUNC_TEMPLATE

    else:
        NETWORKNG_SWAGGER_MANAGER_TEMPLATE = TEMPLATE_FOLDER + \
            NETWORKNG_SWAGGER_MANAGER_TEMPLATE
        CHILD_MANAGER_ADD_HEADER_TEMPLATE = TEMPLATE_FOLDER + \
            CHILD_MANAGER_ADD_HEADER_TEMPLATE
        CHILD_MANAGER_GET_FUNC_TEMPLATE = TEMPLATE_FOLDER + CHILD_MANAGER_GET_FUNC_TEMPLATE
        CHILD_MANAGER_GET_FUNC_NO_SEMICOLON_TEMPLATE = TEMPLATE_FOLDER + \
            CHILD_MANAGER_GET_FUNC_NO_SEMICOLON_TEMPLATE
        CHILD_MANAGER_POST_FUNC_TEMPLATE = TEMPLATE_FOLDER + \
            CHILD_MANAGER_POST_FUNC_TEMPLATE
        CHILD_MANAGER_PUT_FUNC_TEMPLATE = TEMPLATE_FOLDER + \
            CHILD_MANAGER_PUT_FUNC_TEMPLATE
        CHILD_MANAGER_DELETE_FUNC_TEMPLATE = TEMPLATE_FOLDER + \
             CHILD_MANAGER_DELETE_FUNC_TEMPLATE
     
        CHILD_MANAGER_POST_FUNC_NO_SEMICOLON_TEMPLATE = TEMPLATE_FOLDER + \
            CHILD_MANAGER_POST_FUNC_NO_SEMICOLON_TEMPLATE
        CHILD_MANAGER_IMPORT_PACKAGE_TEMPLATE = TEMPLATE_FOLDER + \
            CHILD_MANAGER_IMPORT_PACKAGE_TEMPLATE
        NETWORKNG_SWAGGER_UNIT_TEST_TEMPLATE = TEMPLATE_FOLDER + \
            NETWORKNG_SWAGGER_UNIT_TEST_TEMPLATE
        CHILD_UNIT_TEST_GET_FUNC_TEMPLATE = TEMPLATE_FOLDER + \
            CHILD_UNIT_TEST_GET_FUNC_TEMPLATE
        CHILD_UNIT_TEST_POST_FUNC_TEMPLATE = TEMPLATE_FOLDER + \
            CHILD_UNIT_TEST_POST_FUNC_TEMPLATE


def createFolder():
    if not os.path.isdir(root_path):
        os.makedirs(root_path)
        showErrorMessages(MESSAGE.INFO, root_path)

    # MODELS

    # print root_path + CODING.SLASH + MODULES
    if not os.path.isdir(root_path + CODING.SLASH + MODELS):
        os.makedirs(root_path + CODING.SLASH + MODELS)
        showErrorMessages(MESSAGE.INFO, root_path +
                          CODING.SLASH + MODELS)
    '''
    if not os.path.isdir(unit_test_root_path):
        os.makedirs(unit_test_root_path)
        showErrorMessages(MESSAGE.INFO, unit_test_root_path)
    if not os.path.isdir(unit_test_root_path + CODING.SLASH + package_path):
        os.makedirs(unit_test_root_path + CODING.SLASH + package_path)
        showErrorMessages(MESSAGE.INFO, unit_test_root_path +
                          CODING.SLASH + package_path)
    '''
    # for folder in folders:
    #
    #	if not os.path.isdir(root_path + folder):
    #		os.makedirs(root_path + folder)


def validateParentModulePath():
    validateStatus = False
    if os.path.isdir(MODULES):
        validateStatus = True
    validateStatus = False
    if os.path.isdir(root_path):
        validateStatus = True
    for folder in folders:
        validateStatus = False
        if os.path.isdir(root_path + folder):
            validateStatus = True
    return validateStatus


def multiple_replace(string, rep_dict):
    pattern = re.compile("|".join([re.escape(k) for k in sorted(
        rep_dict, key=len, reverse=True)]), flags=re.DOTALL)
    return pattern.sub(lambda x: rep_dict[x.group(0)], string)


def createFile(fileName, content):
    text_file = open(fileName, "w")
    text_file.write(content)
    text_file.close()


def appendFile(fileName, content, isTruncate=False):
    with open(fileName, "r+") as f:
        # f.seek(0)
        if isTruncate:
            f.truncate()
        f.write(content)
        f.close()


def getFileContent(file):
    global last_request_cache_key, last_request_cache_content
    fileContent = ""
    if intern(DEV_ENV.LOCAL) is intern(CURRENT_DEV_ENV):
        # opens file with name of "test.txt"
        data = open(os.getcwd() + CODING.SLASH + file, "r").read(20000)
        fileContent = data.strip()
        return fileContent
    else:
        try:
            if intern(last_request_cache_key) is intern(file):
                # print "cached data : " + file
                return last_request_cache_content
            gcontext = ssl.SSLContext(ssl.PROTOCOL_TLSv1)
            data = urllib2.urlopen(file, context=gcontext).read(20000)
            fileContent = data.strip()
            last_request_cache_key = file
            last_request_cache_content = fileContent
        except urllib2.HTTPError as e:
            print('HTTPError = ' + str(e.code))
        except urllib2.URLError as e:
            print('URLError = ' + str(e.reason))
        except Exception as e:
            print('generic exception: ' + str(e))
        return fileContent


def replaceAndCreateCodingContent(template_file):
    # print template_file
    temp_file_content = multiple_replace(
        getFileContent(template_file),  child_replacement)
    # print "content " + template_file
    return temp_file_content


def insertOtherString(source_str, insert_str, pos):
    return source_str[:pos]+insert_str+source_str[pos:]


def childInsertMember(childInnerTemplate, insertingModule, subType):
    templateDataPath = insertingModule

    # showErrorMessages(MESSAGE.ERROR,  "childInsertMember " + templateDataPath)
    # TODO REMOVE
    # UNIT TEST CLASSI KOMPLE REMOVE
    # if subType == 2:
    #   removeChildContent(childInnerTemplate = childInnerTemplate, removingModule = insertingModule)
    #  generic_child_inner_template_content = replaceAndCreateCodingContent(childInnerTemplate)
    # data = open(templateDataPath ,"r").read(500000)

    removeChildContent(childInnerTemplate=childInnerTemplate,
                       removingModule=insertingModule)
    generic_child_inner_template_content = replaceAndCreateCodingContent(
        childInnerTemplate)
    data = open(templateDataPath, "r").read(500000)

    # if subType == 2:
    # print "data : " + generic_child_inner_template_content
    # import package
    if subType == 0:
        subTypeString = model_package
        child_inner_index = str(data.strip()).index(
            subTypeString) + len(subTypeString) + 1
        fileContent = insertOtherString(str(data.strip(
        )), generic_child_inner_template_content + CODING.NEWLINE, child_inner_index)
    elif subType == 1:
        subTypeString = request_func
        child_inner_index = str(data.strip()).index(
            subTypeString) + len(subTypeString) + 1
        fileContent = insertOtherString(str(data.strip(
        )), CODING.NEWLINE + generic_child_inner_template_content + CODING.NEWLINE, child_inner_index)
    elif subType == 2:
        subTypeString = unit_test_func
        child_inner_index = str(data.strip()).index(
            subTypeString) + len(subTypeString) + 1
        fileContent = insertOtherString(str(data.strip(
        )), CODING.SPACE_AFTER + generic_child_inner_template_content + CODING.NEWLINE + CODING.NEWLINE, child_inner_index)

    appendFile(fileName=templateDataPath, content=fileContent)


def removeChildContent(childInnerTemplate, removingModule):
    # templateDataPath =  os.getcwd() + SWIFT_ROOT_PATH + package_path + CODING.SLASH  + removingModule
    templateDataPath = removingModule
    generic_child_inner_template_content = replaceAndCreateCodingContent(
        childInnerTemplate)
    # print generic_child_inner_template_content
    data = open(templateDataPath, "r").read(500000)
    remove_child_replacement = {generic_child_inner_template_content: ""}
    remove_replace_content = data.strip().replace(
        generic_child_inner_template_content, "")
    # print remove_replace_content
    appendFile(fileName=templateDataPath,
               content=remove_replace_content, isTruncate=True)


def removeChildFile(module, subTemplateFile, subModuleFileName):
    sub_created_filename = param_package + subModuleFileName
    showErrorMessages(MESSAGE.INFO, sub_created_filename)
    # model wirefamre replacement
    sub_created_file_path = root_path + module + CODING.SLASH + sub_created_filename
    if os.path.exists(sub_created_file_path):
        os.remove(sub_created_file_path)


def createSubModule(module, subTemplateFile, subModuleFileName):
    # WIREFRAME operations BEGIN
    sub_created_filename = param_package + subModuleFileName
    showErrorMessages(MESSAGE.INFO, sub_created_filename)
    # model wirefamre replacement
    sub_created_file_content = multiple_replace(
        getFileContent(subTemplateFile),  child_replacement)
    sub_created_file_path = root_path + module + CODING.SLASH + sub_created_filename
    createFile(sub_created_file_path, sub_created_file_content)
    # WIREFRAME operations END


def createParentModules():
    # ,presenter_filename, view_filename,interactor_filename,wireframe_filename
    global manager_filename, unit_test_filename, manager_file_path
    # NETWORKING SWAGGER MANAGER operations BEGIN
    manager_filename = param_serviceName + manager_filename
    showErrorMessages(MESSAGE.INFO, manager_filename)
    # model manager replacement
    manager_file_content = multiple_replace(getFileContent(
        NETWORKNG_SWAGGER_MANAGER_TEMPLATE),  replacement)
    # print manager_file_content
    # manager file create
    manager_file_path = root_path + CODING.SLASH + manager_filename

    # showErrorMessages(MESSAGE.ERROR,manager_file_path)
    createFile(manager_file_path, manager_file_content)
    # NETWORKING SWAGGER MANAGER operations END


generatedModels = []


def createUnitTestModule():
    global unit_test_filename, unit_test_file_content, replacement, child_replacement, unit_test_file_path, NETWORKNG_SWAGGER_UNIT_TEST_TEMPLATE
    if IS_ENABLE_UNIT_TEST_GENERATE == True:
        unit_test_filename = param_serviceName + unit_test_filename
        # showErrorMessages(MESSAGE.INFO,unit_test_filename)
        replacement = {"[SERVICE_NAME]": param_serviceName,
                       "[PACKAGE_NAME]": param_package}
        unit_test_file_content = multiple_replace(getFileContent(
            NETWORKNG_SWAGGER_UNIT_TEST_TEMPLATE),  replacement)

        unit_test_file_path = unit_test_root_path + \
            package_path + CODING.SLASH + unit_test_filename
        createFile(unit_test_file_path, unit_test_file_content)

        oldModelPath = root_path + CODING.SLASH + MODULES + CODING.SLASH + MODELS
        # print oldModelPath
        for model in generatedModels:
            # print root_path + CODING.SLASH + MODULES + CODING.SLASH + MODELS + CODING.SLASH + model[0]
            child_replacement = {"[PACKAGE_NAME]": param_package,
                                 "[MODEL_NAME]": "models" + CODING.DOT + model[0]}
            childInsertMember(childInnerTemplate=CHILD_MANAGER_IMPORT_PACKAGE_TEMPLATE,
                              insertingModule=unit_test_file_path, subType=0)


def runSwaggerModelOperations():
    global child_replacement

    oldModelPath = os.getcwd() + CODING.SLASH + SWAGGER_CLIENT_FILEPATH
    swaggerRootPath = os.getcwd() + CODING.SLASH + SWAGGER_CLIENT_ROOT_PATH
    for model in getModelsAndReplacePackage(oldModelPath, param_package):
        os.rename(oldModelPath + CODING.SLASH + model[0] + SWIFT, root_path +
                  CODING.SLASH + MODELS + CODING.SLASH + model[0] + SWIFT)
        generatedModels.append(model)

    if os.path.isdir(oldModelPath):
        shutil.rmtree(oldModelPath)
    if os.path.isdir(swaggerRootPath):
        shutil.rmtree(swaggerRootPath)


def getModelsAndReplacePackage(path, packageName):
    showErrorMessages(MESSAGE.ERROR,  "hope " + path)
    subList = os.listdir(path)
    # line split folde rname
    replaceModelPackage(path, packageName, subList)
    listNew = list(map(lambda x:  re.split(SWIFT, x), subList))
    return listNew


def getModels(path):
    subList = os.listdir(path)
    # line split folde rname
    listNew = list(map(lambda x:  re.split(SWIFT, x), subList))
    return listNew


def replaceModelPackage(path, packageName, subList):
    packageName = 'import ' + packageName + "\n" + 'import Foundation'
    for subItem in subList:
        with open(path+subItem, "r") as file:
            lineDatas = file.readlines()
        # line number
        index = 0
        for line in lineDatas:
            if line.__contains__('import'):
                lineDatas[index] = packageName

            if line.__contains__('Codable'):
                newParentLine = lineDatas[index].replace(
                    "Codable", "Serializable")
                lineDatas[index] = newParentLine

            if line.__contains__('https://github.com/swagger-api/swagger-codegen'):
                newCommentLine1 = lineDatas[index].replace(
                    "https://github.com/swagger-api/swagger-codegen", "https://github.com/oneframemobile/networking-swagger-swift")
                lineDatas[index] = newCommentLine1

            if line.__contains__('swagger-codegen'):
                newCommentLine2 = lineDatas[index].replace(
                    "swagger-codegen", "oneframemobile")
                lineDatas[index] = newCommentLine2

            index += 1
        with open(path+subItem, 'w') as file:
            file.writelines(lineDatas)


def runFuncSwaggerGenerator(Functions):
    global child_replacement
    generateApiFuncCount = 0
    for func in Functions:

        if intern(func.httpMethod) is intern("get"):
            showErrorMessages(MESSAGE.INFO,  func.funcName +
                              " api func generating...")
            child_replacement = {"[FUNC_NAME]": func.funcName, "[RESULT_MODEL_NAME]": func.resultModel,
                                 "[QUERY_PATH]": func.queryFormula == "" and func.pathFormula or func.queryFormula,
                                 "[FUNC_PARAM]": func.funcInlineParam}
            childInsertMember(childInnerTemplate=CHILD_MANAGER_GET_FUNC_TEMPLATE,
                              insertingModule=manager_file_path, subType=1)
            generateApiFuncCount = generateApiFuncCount + 1

        elif intern(func.httpMethod) is intern("post"):

            # child_replacement = {"[FUNC_NAME]": func.name, "[RESULT_MODEL_NAME]": func.resultModel, "[QUERY_PATH]": func.queryFormula ==
            #                      "" and func.pathFormula or func.queryFormula, "[FUNC_PARAM]": func.funcInlineParam, "[REQUEST_MODEL_NAME]": funcBodyInlineParam}
            postSpesificPath = func.queryFormula == "" and func.pathFormula or func.queryFormula
            postSpesificPath = postSpesificPath == "" and "\"" + \
                func.path+"\"" or postSpesificPath
            child_replacement = {"[FUNC_NAME]": func.funcName, "[RESULT_MODEL_NAME]": func.resultModel,
                                 "[QUERY_PATH]": postSpesificPath, "[FUNC_PARAM]": func.funcInlineParam,
                                 "[FUNC_PARAM_BODY]": func.bodyFormula == "" and func.formDataFormula or func.bodyFormula}
            # else:
            #     child_replacement = {"[FUNC_NAME]": func.name, "[RESULT_MODEL_NAME]": func.response, "[QUERY_PATH]": func.querypath(
            #     ), "[FUNC_PARAM]": "", "[REQUEST_MODEL_NAME]": funcBodyInlineParam}
            childInsertMember(childInnerTemplate=CHILD_MANAGER_POST_FUNC_TEMPLATE,
                              insertingModule=manager_file_path, subType=1)
            generateApiFuncCount = generateApiFuncCount + 1
        

        elif intern(func.httpMethod) is intern("put"):
                        # child_replacement = {"[FUNC_NAME]": func.name, "[RESULT_MODEL_NAME]": func.resultModel, "[QUERY_PATH]": func.queryFormula ==
            #                      "" and func.pathFormula or func.queryFormula, "[FUNC_PARAM]": func.funcInlineParam, "[REQUEST_MODEL_NAME]": funcBodyInlineParam}
            putSpesificPath = func.queryFormula == "" and func.pathFormula or func.queryFormula
            putSpesificPath = putSpesificPath == "" and "\"" + \
                func.path+"\"" or putSpesificPath
            child_replacement = {"[FUNC_NAME]": func.funcName, "[RESULT_MODEL_NAME]": func.resultModel,
                                 "[QUERY_PATH]": putSpesificPath == "" and "\"\"" or putSpesificPath, "[FUNC_PARAM]": func.funcInlineParam,
                                 "[FUNC_PARAM_BODY]": func.bodyFormula == "" and func.formDataFormula or func.bodyFormula}
            # else:
            #     child_replacement = {"[FUNC_NAME]": func.name, "[RESULT_MODEL_NAME]": func.response, "[QUERY_PATH]": func.querypath(
            #     ), "[FUNC_PARAM]": "", "[REQUEST_MODEL_NAME]": funcBodyInlineParam}
            childInsertMember(childInnerTemplate=CHILD_MANAGER_PUT_FUNC_TEMPLATE,
                              insertingModule=manager_file_path, subType=1)
            generateApiFuncCount = generateApiFuncCount + 1
        else:
            deleteSpesificPath = func.queryFormula == "" and func.pathFormula or func.queryFormula
            deleteSpesificPath = deleteSpesificPath == "" and "\"" + \
                func.path+"\"" or deleteSpesificPath
            func.bodyFormula =  func.bodyFormula == "" and func.formDataFormula or func.bodyFormula
            func.bodyFormula =  deleteSpesificPath.__contains__(func.bodyFormula) == "" and func.formDataFormula or "\"\""
            lineSum = ""
        #             let jsonData = try? JSONSerialization.data(withJSONObject: [FUNC_PARAM_BODY], options: .prettyPrinted)
        # let jsonString = String(data: jsonData!, encoding: .utf8)
            if deleteSpesificPath.__contains__(func.bodyFormula):
                line1 = "let jsonData = try? JSONSerialization.data(withJSONObject: "+func.bodyFormula+", options: .prettyPrinted)"
                line2 = "let jsonString = String(data: jsonData!, encoding: .utf8)"
                lineSum = line1 + "\n" + line2
            else:
                print("false")
                func.bodyFormula = "\"\""
            child_replacement = {"[FUNC_NAME]": func.funcName, "[RESULT_MODEL_NAME]": func.resultModel,
                                 "[QUERY_PATH]": deleteSpesificPath , "[FUNC_PARAM]": func.funcInlineParam,
                                 "[JSON_VALUE_KEY]": lineSum != "" and "jsonString" or "\"\""  ,
                                 "[JSON_VALUE_KEY2]": lineSum}
            # else:
            #     child_replacement = {"[FUNC_NAME]": func.name, "[RESULT_MODEL_NAME]": func.response, "[QUERY_PATH]": func.querypath(
            #     ), "[FUNC_PARAM]": "", "[REQUEST_MODEL_NAME]": funcBodyInlineParam}
            childInsertMember(childInnerTemplate=CHILD_MANAGER_DELETE_FUNC_TEMPLATE,
                              insertingModule=manager_file_path, subType=1)
            generateApiFuncCount = generateApiFuncCount + 1
        generateApiFuncCount = generateApiFuncCount + 1
        # print func.funcName

    showErrorMessages(MESSAGE.INFO, str(
        generateApiFuncCount) + " api func generated")


def runRetrofitParser():
    generateApiFuncCount = 0
    oldApiPath = os.getcwd() + CODING.SLASH + SWAGGER_CLIENT_FILEPATH + "api/"
    subList = os.listdir(oldApiPath)
    for apiFile in subList:
        apiFilePath = oldApiPath + apiFile

        with open(apiFilePath) as fp:
            lines = fp.readlines()

            clazz = Clazz.parse(lines)
            showErrorMessages(MESSAGE.INFO, str(
                len(clazz.functions)) + str(clazz.name) + " api func generating...")
            generateApiFuncCount += generateNetworkingFunc(clazz.functions)
            if IS_ENABLE_UNIT_TEST_GENERATE == True:
                generateUnitTestFunc(clazz.functions)
    # print len(clazz.functions)
    '''
    public GenericObjectRequest [FUNC_NAME](final NetworkResponseListener<[RESULT_MODEL_NAME], ServiceErrorModel> listener) {
         return manager.get("[QUERY_PATH]", listener);
     }
       public GenericObjectRequest [FUNC_NAME]([REQUEST_MODEL_NAME] model, final NetworkResponseListener<[RESULT_MODEL_NAME], ServiceErrorModel> listener) {
       return manager.post("[QUERY_PATH]", model, listener);
     }
    '''
    # print clazz.functions[0].querypath()
    showErrorMessages(MESSAGE.INFO, str(
        generateApiFuncCount) + " api func generated")
    if os.path.isdir(oldApiPath):
        shutil.rmtree(oldApiPath)
    if os.path.isdir(os.getcwd() + CODING.SLASH + "src/main/java/io/"):
        shutil.rmtree(os.getcwd() + CODING.SLASH + "src/main/java/io/")

    del lines


def generateNetworkingFunc(Functions):
    global child_replacement
    generateApiFuncCount = 0
    for func in Functions:
        showErrorMessages(MESSAGE.INFO,  func.name + " api func generating...")
        hasInlineParam = False
        funcInlineParam = ""
        funcBodyInlineParam = ""
        if len(func.parameters) > 0:
            for param in func.parameters:
                # print param.name + " " + param.clazz + " type : " + param.annotation
                if param.annotation == "Query" or param.annotation == "Path":
                    hasInlineParam = True
                    funcInlineParam += "," + param.clazz + " " + param.name
                if param.annotation == "Body":
                    funcBodyInlineParam = param.clazz
            # print param.name + " " + param.clazz + " type : " + param.annotation
            # print func.bodyparameter

# print func.name + " " + func.api.method + " " + func.api.address + " " + func.response + " " + func.querypath()
# GET FUNC
        if intern(func.api.method) is intern("GET"):
            if hasInlineParam == True:
                child_replacement = {"[FUNC_NAME]": func.name, "[RESULT_MODEL_NAME]": func.response,
                                     "[QUERY_PATH]": func.querypath(), "[FUNC_PARAM]": funcInlineParam}
            else:
                child_replacement = {"[FUNC_NAME]": func.name, "[RESULT_MODEL_NAME]": func.response,
                                     "[QUERY_PATH]": func.querypath(), "[FUNC_PARAM]": ""}
            childInsertMember(childInnerTemplate=CHILD_MANAGER_GET_FUNC_TEMPLATE,
                              insertingModule=manager_file_path, subType=1)
            generateApiFuncCount = generateApiFuncCount + 1
        elif intern(func.api.method) is intern("POST"):
            if hasInlineParam == True:
                child_replacement = {"[FUNC_NAME]": func.name, "[RESULT_MODEL_NAME]": func.response, "[QUERY_PATH]": func.querypath(
                ), "[FUNC_PARAM]": funcInlineParam, "[REQUEST_MODEL_NAME]": funcBodyInlineParam}
            else:
                child_replacement = {"[FUNC_NAME]": func.name, "[RESULT_MODEL_NAME]": func.response, "[QUERY_PATH]": func.querypath(
                ), "[FUNC_PARAM]": "", "[REQUEST_MODEL_NAME]": funcBodyInlineParam}
            childInsertMember(childInnerTemplate=CHILD_MANAGER_POST_FUNC_TEMPLATE,
                              insertingModule=manager_file_path, subType=1)
            generateApiFuncCount = generateApiFuncCount + 1
    return generateApiFuncCount


def generateUnitTestFunc(Functions):
    global child_replacement, unit_test_file_path
    for func in Functions:
        # showErrorMessages(MESSAGE.INFO,  func.name + " unit test func generating...")
        hasInlineParam = False
        funcInlineParam = ""
        funcBodyInlineParam = ""
        if len(func.parameters) > 0:
            for param in func.parameters:
                # print param.name + " " + param.clazz + " type : " + param.annotation
                if param.annotation == "Query" or param.annotation == "Path":
                    hasInlineParam = True
                    if intern(str(param.clazz)) is intern("String"):
                        funcInlineParam += "," + "\"test\""
                    elif intern(str(param.clazz)) is intern("Integer"):
                        funcInlineParam += "," + "1"
                    elif intern(str(param.clazz)) is intern("Long"):
                        funcInlineParam += "," + "1L"
                    elif intern(str(param.clazz)) is intern("Float"):
                        funcInlineParam += "," + "1F"
                if param.annotation == "Body":
                    funcBodyInlineParam = param.clazz
            # print param.name + " " + param.clazz + " type : " + param.annotation
            # print func.bodyparameter

# print func.name + " " + func.api.method + " " + func.api.address + " " + func.response + " " + func.querypath()
# GET FUNC
# '''
        if intern(func.api.method) is intern("GET"):

            if hasInlineParam == True:
                # showErrorMessages(MESSAGE.ERROR,"funcInlineParam : " + funcInlineParam)
                child_replacement = {"[FUNC_NAME]": func.name, "[RESULT_MODEL_NAME]": func.response,
                                     "[SERVICE_NAME]": param_serviceName, "[FUNC_PARAM]": funcInlineParam}
            else:
                child_replacement = {"[FUNC_NAME]": func.name, "[RESULT_MODEL_NAME]": func.response,
                                     "[SERVICE_NAME]": param_serviceName, "[FUNC_PARAM]": ""}
            childInsertMember(childInnerTemplate=CHILD_UNIT_TEST_GET_FUNC_TEMPLATE,
                              insertingModule=unit_test_file_path, subType=2)
        elif intern(func.api.method) is intern("POST"):
            print("aa")
            if hasInlineParam == True:
                child_replacement = {"[FUNC_NAME]": func.name, "[RESULT_MODEL_NAME]": func.response, "[QUERY_PATH]": func.querypath(
                ), "[FUNC_PARAM]": funcInlineParam, "[REQUEST_MODEL_NAME]": funcBodyInlineParam, "[SERVICE_NAME]": param_serviceName}
            else:
                child_replacement = {"[FUNC_NAME]": func.name, "[RESULT_MODEL_NAME]": func.response, "[QUERY_PATH]": func.querypath(
                ), "[FUNC_PARAM]": "", "[REQUEST_MODEL_NAME]": funcBodyInlineParam, "[SERVICE_NAME]": param_serviceName}
            childInsertMember(childInnerTemplate=CHILD_UNIT_TEST_POST_FUNC_TEMPLATE,
                              insertingModule=unit_test_file_path, subType=2)


# coding start
# networking-swagger -url -serviceName
if len(sys.argv) >= 3:
    param_url = str(sys.argv[1])
    # param_package = str(sys.argv[2])
    param_serviceName = str(sys.argv[2])
    # http swagger url content print len(swagger_root_http_url.split('http'))
    for url_split_path in param_url.split(CODING.SLASH):
        if intern(url_split_path) is intern('swagger'):
            break
        swagger_root_http_url += url_split_path + CODING.SLASH
    # set env template sources
    initVariables()
    # init root Path
    root_path = os.getcwd() + SWIFT_ROOT_PATH
    unit_test_root_path = os.getcwd() + JAVA_ANDROID_UNIT_TEST_ROOT_PATH

    # print root_path
    replacement = {"[SERVICE_NAME]": param_serviceName,
                   "[URL]": swagger_root_http_url}
    # creatae networking-swagger-java folders
    createFolder()

    # swagger-codegen generate -i http://petstore.swagger.io/v2/swagger.json -l swift4 -Dmodels
    swagger_codegen_homebrew_cmd = 'swagger-codegen generate -i ' + \
        param_url + ' -l swift4 -Dmodels'
    os.system(swagger_codegen_homebrew_cmd)

    createParentModules()
    IS_ENABLE_UNIT_TEST_GENERATE = False

    # swagger model replace package and move MODELS
    runSwaggerModelOperations()
    # createUnitTestModule()

    swaggerFunctions = getSwaggerFunctionInfo(param_url)
    if swaggerFunctions.count > 0:
        runFuncSwaggerGenerator(swaggerFunctions)
    else:
        showErrorMessages(MESSAGE.ERROR, "Swagger Functions not found")


else:
    showErrorMessages(
        MESSAGE.ERROR, "networking-swagger -url -package -serviceName")
    showErrorMessages(MESSAGE.ERROR, "min 3 arguments in commands")
    '''

    elif intern(param_url) is intern(sub_module_type) and len(sys.argv) == 5 and str(sys.argv[4]).lower() == "remove".lower():
        sub_module = str(sys.argv[3])
        child_replacement = { "[MODEL]" : parent_module , "[modelLowerCase]" : parent_module.lower(), "[SUB]" : sub_module }
        removeChildContent(childInnerTemplate=CHILD_PROTOCOL_WIREFRAME_MODULE_METHOD_TEMPLATE, removingModule=PROTOCOLS)
        removeChildContent(childInnerTemplate=CHILD_PROTOCOL_INNER_MODULE_TEMPLATE, removingModule=PROTOCOLS)

        removeChildContent(childInnerTemplate=CHILD_WIFRAME_MODULE_METHOD_INNER_TEMPLATE, removingModule=WIREFRAME)
        removeChildContent(childInnerTemplate=CHILD_INTERACTOR_PRESENTER_MODULE_FIELD_TEMPLATE, removingModule = INTERACTOR)
        removeChildContent(childInnerTemplate=CHILD_INTERACTOR_INNER_MODULE_TEMPLATE, removingModule=INTERACTOR)
        removeChildFile(module=PRESENTER,subTemplateFile=CHILD_PRESENTER_TEMPLATE,subModuleFileName=sub_module + presenter_filename)
        removeChildFile(module=VIEW,subTemplateFile=CHILD_VIEW_TEMPLATE,subModuleFileName=sub_module + view_filename)

    elif intern(param_url) is intern(sub_module_type) and len(sys.argv) != 4:
        showErrorMessages(MESSAGE.ERROR,"viperize -typeName -parentModuleName -subModule")
        showErrorMessages(MESSAGE.ERROR,"-subModule command has not found")
    else:
        showErrorMessages(MESSAGE.ERROR,"viperize -typeName -parentModuleName -subModule")
        showErrorMessages(MESSAGE.ERROR,"-typeName command is not correct")
        showErrorMessages(MESSAGE.ERROR,"for parent module is use to -p , for sub module is use to -s")
'''
# os.system("rm -rf " + param)
# showErrorMessages(MESSAGE.SUCCESS,"child")
# os.path.isdir("/home/el")
# print type(protocol_file_content)

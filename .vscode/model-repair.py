import os
import sys
import re
import urllib2
import ssl
import shutil

SWAGGER_CLIENT_FILEPATH = "SwaggerClient/Classes/Swaggers/Models/"

def runSwaggerModelOperations():
    global child_replacement
    #showErrorMessages(MESSAGE.ERROR,  "hope " + manager_file_path)
    #print os.getcwd() + CODING.SLASH + SWAGGER_CLIENT_FILEPATH + "model/"
    oldModelPath = os.getcwd() + CODING.SLASH + SWAGGER_CLIENT_FILEPATH
    for model in getModelsAndReplacePackage(oldModelPath, param_package):
        #os.rename(oldModelPath + CODING.SLASH + model[0] + JAVA, root_path +
                  CODING.SLASH + MODULES + CODING.SLASH + MODELS + CODING.SLASH + model[0] + JAVA)
        #generatedModels.append(model)
        #print root_path + CODING.SLASH + MODULES + CODING.SLASH + MODELS + CODING.SLASH + model[0]
        #child_replacement = {"[PACKAGE_NAME]": param_package,
                             "[MODEL_NAME]": "models" + CODING.DOT + model[0]}
        #childInsertMember(childInnerTemplate=CHILD_MANAGER_IMPORT_PACKAGE_TEMPLATE,
                          insertingModule=manager_file_path, subType=0)

    if os.path.isdir(oldModelPath):
        shutil.rmtree(oldModelPath)
    if os.path.isdir("docs"):
        shutil.rmtree("docs")
    if os.path.isdir(os.getcwd() + CODING.SLASH + "src/test"):
        shutil.rmtree(os.getcwd() + CODING.SLASH + "src/test")
        
def getModelsAndReplacePackage(path, packageName):
    showErrorMessages(MESSAGE.ERROR,  "hope " + path)
    subList = os.listdir(path)
    # line split folde rname
    replaceModelPackage(path, packageName, subList)
    listNew = list(map(lambda x:  re.split('.java', x), subList))
    return listNew


def replaceModelPackage(path, packageName, subList):
    packageName = 'import '+packageName + "\n"
    for subItem in subList:
        with open(path+subItem, "r") as file:
            lineDatas = file.readlines()
        # line number
        index = 0
        for line in lineDatas:
            if line.__contains__('import'):
                lineDatas[index] = packageName
    '''
            if line.__contains__('import io.swagger.annotations.ApiModel'):
                lineDatas[index] = ""

            if line.__contains__('@javax.annotation.Generated'):
                lineDatas[index] = ""

            if line.__contains__('ApiModelProperty'):
                lineDatas[index] = ""
    '''
    '''
            if line.__contains__('import io.swagger.client.model'):
                dotPackageSplit = lineDatas[index].split(".")
                lineDatas[index] = "import " + param_package + CODING.DOT + MODULES + \
                    CODING.DOT + MODELS + CODING.DOT + \
                    dotPackageSplit[len(dotPackageSplit)-1]
    '''
            index += 1
        with open(path+subItem, 'w') as file:
            file.writelines(lineDatas)

runSwaggerModelOperations()
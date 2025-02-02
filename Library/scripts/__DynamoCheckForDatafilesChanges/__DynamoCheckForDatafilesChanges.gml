/// @param outputArray
/// @param projectDirectory
/// @param targetDirectory

function __DynamoCheckForDatafilesChanges(_output, _projectDirectory, _targetDirectory)
{
    var _datafilesDynamoPath       = _projectDirectory + "datafilesDynamo\\";
    var _datafilesDynamoPathLength = string_length(_datafilesDynamoPath);
    
    var _oldDictionary = global.__dynamoFileDictionary;
    var _oldPaths = variable_struct_get_names(_oldDictionary);
    
    var _newDictionary = __DynamoDatafilesDictionary(_datafilesDynamoPath, {});
    var _newPaths = variable_struct_get_names(_newDictionary);
    
    global.__dynamoFileDictionary = _newDictionary;
    
    
    
    var _deleteArray          = [];
    var _createDirectoryArray = [];
    var _copyArray            = [];
    
    var _i = 0;
    repeat(array_length(_oldPaths))
    {
        var _path = _oldPaths[_i];
        if (!variable_struct_exists(_newDictionary, _path))
        {
            __DynamoTrace("\"", _path, "\" has been deleted");
            array_push(_deleteArray, _path);
        }
        
        ++_i;
    }
    
    var _i = 0;
    repeat(array_length(_newPaths))
    {
        var _path = _newPaths[_i];
        if (!variable_struct_exists(_oldDictionary, _path))
        {
            __DynamoTrace("\"", _path, "\" has been created");
            
            if (_newDictionary[$ _path].__isDirectory)
            {
                array_push(_createDirectoryArray, _path);
            }
            else
            {
                array_push(_copyArray, _path);
            }
        }
        else
        {
            var _oldHash = _oldDictionary[$ _path].__dataHash;
            var _newHash = _newDictionary[$ _path].__dataHash;
            
            if (_oldHash != _newHash)
            {
                __DynamoTrace("Hash for \"", _path, "\" has changed (old = \"", _oldHash, "\" vs. new = \"", _newHash, "\"");
                array_push(_copyArray, _path);
            }
        }
        
        ++_i;
    }
    
    var _i = 0;
    repeat(array_length(_deleteArray))
    {
        var _sourcePath = _deleteArray[_i];
        var _localPath = string_delete(_sourcePath, 1, _datafilesDynamoPathLength);
        
        if (!is_array(_output)) _output = [];
        array_push(_output, _localPath);
        
        var _destinationPath = _targetDirectory + _localPath;
        __DynamoTrace("Deleting \"", _destinationPath, "\"");
        
        if (_oldDictionary[$ _sourcePath].__isDirectory)
        {
            directory_destroy(_destinationPath);
        }
        else
        {
            file_delete(_destinationPath);
        }
        
        ++_i;
    }
    
    array_sort(_createDirectoryArray, true);
    
    var _i = 0;
    repeat(array_length(_createDirectoryArray))
    {
        var _sourcePath = _createDirectoryArray[_i];
        var _localPath = string_delete(_sourcePath, 1, _datafilesDynamoPathLength);
        
        if (!is_array(_output)) _output = [];
        array_push(_output, _localPath);
        
        var _destinationPath = _targetDirectory + _localPath;
        
        __DynamoTrace("Creating \"", _destinationPath, "\"");
        directory_create(_destinationPath);
        
        ++_i;
    }
    
    var _i = 0;
    repeat(array_length(_copyArray))
    {
        var _sourcePath = _copyArray[_i];
        var _localPath = string_delete(_sourcePath, 1, _datafilesDynamoPathLength);
        
        if (!is_array(_output)) _output = [];
        array_push(_output, _localPath);
        
        var _destinationPath = _targetDirectory + _localPath;
        
        __DynamoTrace("Copying \"", _sourcePath, "\" to \"", _destinationPath, "\"");
        file_copy(_sourcePath, _destinationPath);
        
        ++_i;
    }
    
    return _output;
}
param (
    [string]$subDirectory = "."
)

# .\compile-json.ps1 -subDirectory "owngeo"
# 获取当前目录
$currentDirectory = Get-Location

# 将子目录路径转换为完整路径
$targetDirectory = Join-Path -Path $currentDirectory -ChildPath $subDirectory

# 定义一个递归函数来处理指定目录及其子目录下的所有.json文件
function Compile-JsonFiles {
    param (
        [string]$dir
    )

    # 获取指定目录下的所有文件和文件夹
    $items = Get-ChildItem -Path $dir -Force

    foreach ($item in $items) {
        # 如果是目录且以.开头，则跳过
        if ($item.PSIsContainer -and $item.Name -match '^\.') {
            continue
        }

        # 如果是文件夹，则递归调用自己
        if ($item.PSIsContainer) {
            Compile-JsonFiles -dir $item.FullName
        }

        # 如果是.json文件，则编译
        if ($item.Extension -eq ".json") {
            $jsonFilePath = $item.FullName
            $binaryFilePath = [System.IO.Path]::ChangeExtension($jsonFilePath, ".srs")

            # 调用sing-box编译.json文件为二进制文件
            & sing-box rule-set compile $jsonFilePath

            if ($LASTEXITCODE -eq 0) {
                Write-Host "编译成功: $jsonFilePath -> $binaryFilePath"
            } else {
                Write-Host "编译失败: $jsonFilePath"
            }
        }
    }
}

# 调用函数并传递指定目录
Compile-JsonFiles -dir $targetDirectory

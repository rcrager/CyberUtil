#Get Live AD Computer Resource statistics

$Computers = Get-Content ./Servers.txt
$table = @()
foreach ($item in $Computers){
    $row = "" | Select-Object "Server","CPU (%)","Cores","Threads","Memory (%)", "RAM","Notes"
    $Processor = (Get-WmiObject -ComputerName $item -Class win32_processor -ErrorAction SilentlyContinue | Measure-Object -Property LoadPercentage -Average | Select-Object Average).Average
    $Cores = @(Get-WmiObject -ComputerName $item -class win32_processor | Select-Object -Property NumberOfCores, NumberOfLogicalProcessors)
    $RAM = [math]::Round((Get-WmiObject -ComputerName $item -class win32_ComputerSystem).totalphysicalmemory/1GB,0)
    $ComputerMemory = Get-WmiObject -ComputerName $item -Class win32_operatingsystem -ErrorAction SilentlyContinue
    $Memory = ((($ComputerMemory.TotalVisibleMemorySize - $ComputerMemory.FreePhysicalMemory)*100)/ $ComputerMemory.TotalVisibleMemorySize) 
    $RoundMemory = [math]::Round($Memory, 2)
    $row."Server" = $item
    $row."Cpu (%)" = $Processor
    $row."Cores" = $cores.NumberOfCores
    $row."Threads" = $cores.NumberOfLogicalProcessors
    $row."Memory (%)" = $RoundMemory
    $row."RAM" = $RAM
    $table += $row
}

$table
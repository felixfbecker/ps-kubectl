using namespace System.Management.Automation.Language;
using namespace System.Management.Automation;

Register-ArgumentCompleter -CommandName Get-KubeDeployment -ParameterName Name -ScriptBlock {
    param([string]$commandName, [string]$parameterName, [string]$wordToComplete, [CommandAst]$commandAst, [Hashtable]$fakeBoundParameter)

    $fakeBoundParameter.Remove('Name')

    Get-KubeDeployment @fakeBoundParameter |
        ForEach-Object { $_.Metadata.Name } |
        Where-Object { $_ -like "$wordToComplete*" } |
        ForEach-Object { [CompletionResult]::new($_, $_, [CompletionResultType]::ParameterValue, $_) }
}
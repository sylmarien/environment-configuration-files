###############################################################################
# Profile for PowerShell                                                      #
###############################################################################
# Note: Functions are in the Modules directory and sourced automatically

###############################################################################
# Functions (small ones, alias-like with arguments. For bigger functions, do a module)
# Custom cd to have 'cd -'
Remove-Item Alias:cd
function cd { if ($args[0] -eq '-') { $pwd=$OLDPWD; } else { $pwd=$args[0]; } $tmp=pwd; if ($pwd) { Set-Location $pwd; } Set-Variable -Name OLDPWD -Value $tmp -Scope global; }

function cdh { cd D:\Library\Documents\WindowsPowerShell }
function cdw { cd W:\code }
function .. { cd .. }

###############################################################################
# Aliases
New-Alias touch Touch-File
New-Alias ping Test-Connection
New-Alias ll Get-ChildItem

###############################################################################
# Load posh-git example profile
. 'D:\Library\Documents\WindowsPowerShell\Modules\posh-git\profile.example.ps1'

###############################################################################
# Visual Studio setup for PowerShell

# Move to the directory where vcvarsall.bat is stored
pushd 'C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC'

# Call the .bat file to set the variables in a temporary cmd session and use 'set' to read out all session variables and pipe them into a foreach to iterate over each variable
cmd /c "vcvarsall.bat x64 & set" | foreach {
  # if the line is a session variable
  if( $_ -match "=" )
  {
    $pair = $_.split("=");

    # Set the environment variable for the current PowerShell session
    Set-Item -Force -Path "ENV:\$($pair[0])" -Value "$($pair[1])"
  }
}

# Move back to wherever the prompt was previously
popd

# Linux like make command for nmake
New-Alias make nmake

###############################################################################
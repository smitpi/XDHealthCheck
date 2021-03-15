$FormUserCompare = New-Object -TypeName System.Windows.Forms.Form
[System.Windows.Forms.Button]$btn = $null
[System.Windows.Forms.Label]$lblUsername1 = $null
[System.Windows.Forms.TextBox]$txtUsername1 = $null
[System.Windows.Forms.Label]$lblUsername2 = $null
[System.Windows.Forms.TextBox]$txtUsername2 = $null
function InitializeComponent
{
$btn = (New-Object -TypeName System.Windows.Forms.Button)
$lblUsername1 = (New-Object -TypeName System.Windows.Forms.Label)
$txtUsername1 = (New-Object -TypeName System.Windows.Forms.TextBox)
$lblUsername2 = (New-Object -TypeName System.Windows.Forms.Label)
$txtUsername2 = (New-Object -TypeName System.Windows.Forms.TextBox)
$formUserCompare.SuspendLayout()
#
# lblUsername1
#
$lblUsername1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]10))
$lblUsername1.Name = [System.String]'lblUsername1'
$lblUsername1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]100,[System.Int32]23))
$lblUsername1.TabIndex = 1
$lblUsername1.Text = 'Username1'
$lblUsername1.UseCompatibleTextRendering = $true
#
# txtUsername1
#
$txtUsername1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]120,[System.Int32]10))
$txtUsername1.Name = [System.String]'txtUsername1'
$txtUsername1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]200,[System.Int32]23))
$txtUsername1.TabIndex = 2
#
# lblUsername2
#
$lblUsername2.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]40))
$lblUsername2.Name = [System.String]'lblUsername2'
$lblUsername2.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]100,[System.Int32]23))
$lblUsername2.TabIndex = 3
$lblUsername2.Text = 'Username2'
$lblUsername2.UseCompatibleTextRendering = $true
#
# txtUsername2
#
$txtUsername2.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]120,[System.Int32]40))
$txtUsername2.Name = [System.String]'txtUsername2'
$txtUsername2.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]200,[System.Int32]23))
$txtUsername2.TabIndex = 4
#
# btn
#
$btn.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]220,[System.Int32]70))
$btn.Name = [System.String]'btn'
$btn.Padding = (New-Object -TypeName System.Windows.Forms.Padding -ArgumentList @([System.Int32]3))
$btn.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]100,[System.Int32]23))
$btn.TabIndex = 5
$btn.Text = 'Submit'
$btn.UseVisualStyleBackColor = $true
$btn.add_Click($btn_Click)
$FormUserCompare.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]380,[System.Int32]130))
$FormUserCompare.Controls.Add($lblUsername1)
$FormUserCompare.Controls.Add($txtUsername1)
$FormUserCompare.Controls.Add($lblUsername2)
$FormUserCompare.Controls.Add($txtUsername2)
$FormUserCompare.Controls.Add($btn)
$FormUserCompare.Text = [System.String]'User Compare'
$FormUserCompare.ResumeLayout($true)
Add-Member -InputObject $FormUserCompare -Name btn -Value $btn -MemberType NoteProperty
Add-Member -InputObject $FormUserCompare -Name lblUsername1 -Value $lblUsername1 -MemberType NoteProperty
Add-Member -InputObject $FormUserCompare -Name txtUsername1 -Value $txtUsername1 -MemberType NoteProperty
Add-Member -InputObject $FormUserCompare -Name lblUsername2 -Value $lblUsername2 -MemberType NoteProperty
Add-Member -InputObject $FormUserCompare -Name txtUsername2 -Value $txtUsername2 -MemberType NoteProperty
}
. InitializeComponent

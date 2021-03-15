$FormUserDetail = New-Object -TypeName System.Windows.Forms.Form
[System.Windows.Forms.Button]$btn = $null
[System.Windows.Forms.Label]$lblUsername = $null
[System.Windows.Forms.TextBox]$txtUsername = $null
function InitializeComponent
{
$btn = (New-Object -TypeName System.Windows.Forms.Button)
$lblUsername = (New-Object -TypeName System.Windows.Forms.Label)
$txtUsername = (New-Object -TypeName System.Windows.Forms.TextBox)
$formUserDetail.SuspendLayout()
#
# lblUsername
#
$lblUsername.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]10))
$lblUsername.Name = [System.String]'lblUsername'
$lblUsername.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]100,[System.Int32]23))
$lblUsername.TabIndex = 1
$lblUsername.Text = 'Username'
$lblUsername.UseCompatibleTextRendering = $true
#
# txtUsername
#
$txtUsername.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]120,[System.Int32]10))
$txtUsername.Name = [System.String]'txtUsername'
$txtUsername.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]200,[System.Int32]23))
$txtUsername.TabIndex = 2
#
# btn
#
$btn.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]220,[System.Int32]40))
$btn.Name = [System.String]'btn'
$btn.Padding = (New-Object -TypeName System.Windows.Forms.Padding -ArgumentList @([System.Int32]3))
$btn.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]100,[System.Int32]23))
$btn.TabIndex = 3
$btn.Text = 'Submit'
$btn.UseVisualStyleBackColor = $true
$btn.add_Click($btn_Click)
$FormUserDetail.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]380,[System.Int32]90))
$FormUserDetail.Controls.Add($lblUsername)
$FormUserDetail.Controls.Add($txtUsername)
$FormUserDetail.Controls.Add($btn)
$FormUserDetail.Text = [System.String]'User Detail'
$FormUserDetail.ResumeLayout($true)
Add-Member -InputObject $FormUserDetail -Name btn -Value $btn -MemberType NoteProperty
Add-Member -InputObject $FormUserDetail -Name lblUsername -Value $lblUsername -MemberType NoteProperty
Add-Member -InputObject $FormUserDetail -Name txtUsername -Value $txtUsername -MemberType NoteProperty
}
. InitializeComponent

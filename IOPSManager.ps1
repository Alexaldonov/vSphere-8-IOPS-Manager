Import-Module VMware.VimAutomation.Core -ErrorAction Stop
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic -ErrorAction SilentlyContinue
Import-Module VMware.VimAutomation.Core -ErrorAction SilentlyContinue

function Show-MessageBox($message, $title = "Info") {
    [System.Windows.Forms.MessageBox]::Show(
        $form,
        $message,
        $title,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )
}

function Show-InputBox($prompt, $title, $default) {
    try {
        return [Microsoft.VisualBasic.Interaction]::InputBox($prompt, $title, $default)
    } catch {
        # fallback WinForms
        $form = New-Object System.Windows.Forms.Form
        $form.Text = $title
        $form.Size = New-Object System.Drawing.Size(350,150)
        $form.StartPosition = "CenterParent"

        $label = New-Object System.Windows.Forms.Label
        $label.Text = $prompt
        $label.Location = New-Object System.Drawing.Point(10,10)
        $label.Size = New-Object System.Drawing.Size(320,20)
        $form.Controls.Add($label)

        $textbox = New-Object System.Windows.Forms.TextBox
        $textbox.Location = New-Object System.Drawing.Point(10,40)
        $textbox.Size = New-Object System.Drawing.Size(310,20)
        $textbox.Text = $default
        $form.Controls.Add($textbox)

        $okButton = New-Object System.Windows.Forms.Button
        $okButton.Text = "OK"
        $okButton.Location = New-Object System.Drawing.Point(230,70)
        $okButton.Add_Click({ $form.Tag = $textbox.Text; $form.Close() })
        $form.Controls.Add($okButton)
        $form.AcceptButton = $okButton

        $form.ShowDialog() | Out-Null
        return $form.Tag
    }
}

# --- Main window ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "VM IOPS Limit Manager"
$form.Size = New-Object System.Drawing.Size(700, 580)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# --- Connection fields ---
$labelVCenter = New-Object System.Windows.Forms.Label
$labelVCenter.Text = "vCenter Address (FQDN):"
$labelVCenter.Location = New-Object System.Drawing.Point(20,20)
$labelVCenter.AutoSize = $true
$form.Controls.Add($labelVCenter)

$txtVCenter = New-Object System.Windows.Forms.TextBox
$txtVCenter.Location = New-Object System.Drawing.Point(200,18)
$txtVCenter.Size = New-Object System.Drawing.Size(300,20)
$form.Controls.Add($txtVCenter)

$btnConnect = New-Object System.Windows.Forms.Button
$btnConnect.Text = "Connect"
$btnConnect.Location = New-Object System.Drawing.Point(520,15)
$btnConnect.Width = 120
$form.Controls.Add($btnConnect)
$form.AcceptButton = $btnConnect

# --- VM search type ---
$searchByName = New-Object System.Windows.Forms.RadioButton
$searchByName.Text = "By Name"
$searchByName.Location = New-Object System.Drawing.Point(20,60)
$searchByName.AutoSize = $true
$searchByName.Checked = $true
$form.Controls.Add($searchByName)

$searchById = New-Object System.Windows.Forms.RadioButton
$searchById.Text = "By VM ID"
$searchById.Location = New-Object System.Drawing.Point(120,60)
$searchById.AutoSize = $true
$form.Controls.Add($searchById)

$txtVMSearch = New-Object System.Windows.Forms.TextBox
$txtVMSearch.Location = New-Object System.Drawing.Point(200,58)
$txtVMSearch.Size = New-Object System.Drawing.Size(300,20)
$form.Controls.Add($txtVMSearch)

$btnFindVM = New-Object System.Windows.Forms.Button
$btnFindVM.Text = "Find VM"
$btnFindVM.Location = New-Object System.Drawing.Point(520,55)
$btnFindVM.Width = 120
$btnFindVM.Enabled = $false
$form.Controls.Add($btnFindVM)
$form.AcceptButton = $btnFindVM

# --- Disk Table ---
$grid = New-Object System.Windows.Forms.DataGridView
$grid.Location = New-Object System.Drawing.Point(20,100)
$grid.Size = New-Object System.Drawing.Size(640, 350)
$grid.AutoSizeColumnsMode = 'Fill'
$grid.SelectionMode = 'FullRowSelect'
$grid.MultiSelect = $false
$form.Controls.Add($grid)

# --- Buttons ---
$btnChangeLimit = New-Object System.Windows.Forms.Button
$btnChangeLimit.Text = "Change disk limit"
$btnChangeLimit.Location = New-Object System.Drawing.Point(20,470)
$btnChangeLimit.Width = 180
$btnChangeLimit.Enabled = $false
$form.Controls.Add($btnChangeLimit)

$btnResetAll = New-Object System.Windows.Forms.Button
$btnResetAll.Text = "Reset disks limits"
$btnResetAll.Location = New-Object System.Drawing.Point(220,470)
$btnResetAll.Width = 180
$btnResetAll.Enabled = $false
$form.Controls.Add($btnResetAll)

$btnExit = New-Object System.Windows.Forms.Button
$btnExit.Text = "Exit"
$btnExit.Location = New-Object System.Drawing.Point(520,470)
$btnExit.Width = 120
$form.Controls.Add($btnExit)

function Show-CredentialForm {

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Connect vCenter"
    $form.Size = New-Object System.Drawing.Size(300,180)
    $form.StartPosition = "CenterParent"
    $form.TopMost = $true

    # --- Login ---
    $lblUser = New-Object System.Windows.Forms.Label
    $lblUser.Text = "Login:"
    $lblUser.Location = New-Object System.Drawing.Point(10,10)
    $lblUser.Size = New-Object System.Drawing.Size(260,20)
    $form.Controls.Add($lblUser)

    $txtUser = New-Object System.Windows.Forms.TextBox
    $txtUser.Location = New-Object System.Drawing.Point(10,30)
    $txtUser.Size = New-Object System.Drawing.Size(260,20)
    $form.Controls.Add($txtUser)

    # --- Password ---
    $lblPass = New-Object System.Windows.Forms.Label
    $lblPass.Text = "Password:"
    $lblPass.Location = New-Object System.Drawing.Point(10,60)
    $lblPass.Size = New-Object System.Drawing.Size(260,20)
    $form.Controls.Add($lblPass)

    $txtPass = New-Object System.Windows.Forms.TextBox
    $txtPass.Location = New-Object System.Drawing.Point(10,80)
    $txtPass.Size = New-Object System.Drawing.Size(260,20)
    $txtPass.UseSystemPasswordChar = $true
    $form.Controls.Add($txtPass)

    # --- OK ---
    $btnOK = New-Object System.Windows.Forms.Button
    $btnOK.Text = "OK"
    $btnOK.Location = New-Object System.Drawing.Point(110,110)
    $btnOK.Add_Click({
        $form.Tag = @{
            User = $txtUser.Text
            Pass = $txtPass.Text
        }
        $form.Close()
    })
    $form.Controls.Add($btnOK)
    $form.AcceptButton = $btnOK

    # --- Cancel ---
    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Cancel"
    $btnCancel.Location = New-Object System.Drawing.Point(190,110)
    $btnCancel.Add_Click({
        $form.Tag = $null
        $form.Close()
    })
    $form.Controls.Add($btnCancel)

    $form.ShowDialog() | Out-Null

    if ($form.Tag -eq $null) {
        return $null
    }

    $user = $form.Tag.User
    $pass = $form.Tag.Pass

    $secure = ConvertTo-SecureString $pass -AsPlainText -Force

    return New-Object System.Management.Automation.PSCredential ($user, $secure)
}


# --- Connect vCenter ---
$btnConnect.Add_Click({

    $vcenter = $txtVCenter.Text.Trim()
    if (-not $vcenter) {
        Show-MessageBox "Set vCenter address!"
        return
    }

    if ($script:viConnection -eq $null) {

        try {

            $cred = Show-CredentialForm
            if ($cred -eq $null) { return }

            $script:viConnection =
                Connect-VIServer -Server $vcenter -Credential $cred -ErrorAction Stop

            Show-MessageBox "Connected to $vcenter"

            $btnConnect.Text = "Disconnect"
            $btnFindVM.Enabled = $true

        }
        catch {
            Show-MessageBox "Connection error: $($_.Exception.Message)"
        }

    }
    else {

        try {

            Disconnect-VIServer -Server $script:viConnection -Confirm:$false

            $script:viConnection = $null

            $btnConnect.Text = "Connect"
            $btnFindVM.Enabled = $false

            Show-MessageBox "Disconnected"

        }
        catch {
            Show-MessageBox $_.Exception.Message
        }

    }

})

# --- Search VM ---
$btnFindVM.Add_Click({
    $searchText = $txtVMSearch.Text.Trim()
    if (-not $searchText) { Show-MessageBox "Enter value for search!"; return }
    try {
        if ($searchById.Checked) {
            $vmList = Get-VM | Where-Object { $_.Id -eq $searchText }
        } else {
            $vmList = Get-VM | Where-Object { $_.Name -eq $searchText }
        }
        if (-not $vmList) { Show-MessageBox "VM not found."; return }

        # Create table
        $vmTable = New-Object System.Data.DataTable
        $vmTable.Columns.Add("Name")
        $vmTable.Columns.Add("VMId")
        $vmTable.Columns.Add("ResourcePool")
        $vmTable.Columns.Add("DiskName")
        $vmTable.Columns.Add("SizeGB")
        $vmTable.Columns.Add("IOPSLimit")
        $vmTable.Columns.Add("VMObj",[object])
        $vmTable.Columns.Add("DiskObj",[object])

        foreach ($vm in $vmList) {
            $config = Get-VMResourceConfiguration -VM $vm
            $disks = Get-HardDisk -VM $vm
            foreach ($disk in $disks) {
                $key = ($disk.Id -split '/')[-1]
                $limit = ($config.DiskResourceConfiguration | Where-Object { $_.Key -eq $key }).DiskLimitIOPerSecond
                if ($limit -eq -1 -or -not $limit) { $limit="Unlimited" }
                $row = $vmTable.NewRow()
                $row.Name = $vm.Name
                $row.VMId = $vm.Id
                $row.ResourcePool = $vm.ResourcePool
                $row.DiskName = $disk.Name
                $row.SizeGB = [math]::Round($disk.CapacityGB,2)
                $row.IOPSLimit = $limit
                $row.VMObj = $vm
                $row.DiskObj = $disk
                $vmTable.Rows.Add($row)
            }
        }

        $grid.DataSource = $vmTable
        $grid.Columns["VMObj"].Visible = $false
        $grid.Columns["DiskObj"].Visible = $false
        $btnResetAll.Enabled = $grid.Rows.Count -gt 0
    } catch {
        Show-MessageBox "Error: $($_.Exception.Message)"
    }
})

# --- Set table row ---
$grid.Add_SelectionChanged({
    $btnChangeLimit.Enabled = $grid.CurrentRow -ne $null
})

# --- Change limit ---
$btnChangeLimit.Add_Click({
    if (-not $grid.CurrentRow) { Show-MessageBox "Select disk!"; return }
    $selectedRow = $grid.CurrentRow
    $vm = $selectedRow.Cells["VMObj"].Value
    $disk = $selectedRow.Cells["DiskObj"].Value

    $newLimit = Show-InputBox "Enter new IOPS limit (or -1 for Unlimited):" "Changing limit" ""
    if (-not $newLimit -or ($newLimit -notmatch '^\d+$|-1$')) { Show-MessageBox "Incorrect value."; return }

    try {
        $config = Get-VMResourceConfiguration -VM $vm
        Set-VMResourceConfiguration -Configuration $config -Disk $disk -DiskLimitIOPerSecond $newLimit -Confirm:$false | Out-Null
        Show-MessageBox "Limit for '$($disk.Name)' changed $newLimit"
        $btnFindVM.PerformClick()
    } catch {
        Show-MessageBox "Error: $($_.Exception.Message)"
    }
})

# --- Reset all disks limits ---
$btnResetAll.Add_Click({
    if (-not $grid.DataSource) { Show-MessageBox "No data!"; return }
    foreach ($row in $grid.Rows) {
        $vm = $row.Cells["VMObj"].Value
        $disk = $row.Cells["DiskObj"].Value
        if ($vm -and $disk) {
            $config = Get-VMResourceConfiguration -VM $vm
            Set-VMResourceConfiguration -Configuration $config -Disk $disk -DiskLimitIOPerSecond -1 -Confirm:$false | Out-Null
        }
    }
    Show-MessageBox "All disks now unlimited."
    $btnFindVM.PerformClick()
})

# --- Exit ---
$btnExit.Add_Click({ $form.Close() })

# --- Показ формы ---
[void]$form.ShowDialog()

# This helped me when the client was stuck on a slow connection, downloading a full set of policies finished after 40 minutes.
function Get-CCMBitsTransferProgress {
  $LastByteCount = [int]0
  $BitsJobs = Get-BitsTransfer -AllUsers | Where-Object { ($_.Name -eq 'CCMDTS Job' -or $_.DisplayName -eq 'CCMSETUP DOWNLOAD') -and  $_.JobState -eq 'Transferring' }
  while (($BitsJobs)) {
      $BitsJobs = Get-BitsTransfer -AllUsers | Where-Object { ($_.Name -eq 'CCMDTS Job' -or $_.DisplayName -eq 'CCMSETUP DOWNLOAD') -and $_.JobState -eq 'Transferring'  }
      $BitsJobs |Select-Object -Property 'BytesTotal','BytesTransferred','FilesTotal','FilesTransferred' |% {
          $bytessincelasttime = (([int]$_.BytesTransferred - [int]$LastByteCount))
          $LastByteCount = $_.BytesTransferred
          Write-Progress -Activity 'Bits jobs' -Status $bytessincelasttime -PercentComplete (($_.FilesTransferred / $_.FilesTotal)*100)
          $_
      }
      Start-Sleep -Seconds 1
  }
}

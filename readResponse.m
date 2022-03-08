function PUF = readResponse(path)
  %Read Response from a file to derieve a fingerprint from the PUF
  PUF = readmatrix(path, "FileType","spreadsheet", "Range","C2:C4097");
end
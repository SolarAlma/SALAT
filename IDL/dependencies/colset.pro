pro decomp1
  if !d.name ne 'PS' then device,decomposed=1
end

pro decomp0
  if !d.name ne 'PS' then device,decomposed=0
end

pro colset
  
  col={black:'000000'x,white:'FFFFFF'x, $
       red:'0000FF'x,green:'00FF00'x,blue:'FF0000'x, $
       yellow:'00FFFF'x,cyan:'FFFF00'x,magenta:'FF00FF'x}
  
  defsysv,'!col',col
end

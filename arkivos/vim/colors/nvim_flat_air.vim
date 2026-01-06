" E aqui está o tema correspondente para o Airline:
let g:airline#themes#neoflat#palette = {}

" Cores normais
let s:N1 = [s:neo_dark, s:neo_blue, 0, 2]
let s:N2 = [s:neo_light, s:neo_gray, 7, 8]
let s:N3 = [s:neo_blue, s:neo_dark, 2, 0]
let g:airline#themes#neoflat#palette.normal = airline#themes#generate_color_map(s:N1, s:N2, s:N3)

" Modo Insert
let s:I1 = [s:neo_dark, s:neo_green, 0, 2]
let s:I2 = [s:neo_light, s:neo_gray, 7, 8]
let s:I3 = [s:neo_green, s:neo_dark, 2, 0]
let g:airline#themes#neoflat#palette.insert = airline#themes#generate_color_map(s:I1, s:I2, s:I3)

" Modo Visual
let s:V1 = [s:neo_dark, s:neo_blue, 0, 3]
let s:V2 = [s:neo_light, s:neo_gray, 7, 8]
let s:V3 = [s:neo_blue, s:neo_dark, 3, 0]
let g:airline#themes#neoflat#palette.visual = airline#themes#generate_color_map(s:V1, s:V2, s:V3)

" Modo Replace
let s:R1 = [s:neo_dark, s:neo_green, 0, 1]
let s:R2 = [s:neo_light, s:neo_gray, 7, 8]
let s:R3 = [s:neo_green, s:neo_dark, 1, 0]
let g:airline#themes#neoflat#palette.replace = airline#themes#generate_color_map(s:R1, s:R2, s:R3)

" Modo Inativo
let s:IA = [s:neo_gray, s:neo_dark, 8, 0]
let g:airline#themes#neoflat#palette.inactive = airline#themes#generate_color_map(s:IA, s:IA, s:IA)

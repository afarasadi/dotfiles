#!/bin/zsh
# Renderiza um `Shape` do SwiftUI num PNG, no macOS, sem simulador.
#
#   render_shape.sh Shape.swift ShapeName out.png [opções]
#
# Opções:
#   --mode fill|stroke|trim   (default fill)
#   --trim T                  progresso 0...1 quando --mode trim
#   --canvas W H              tamanho da imagem (default 1254 1254)
#   --frame X Y W H           onde o shape é posicionado (default: canvas inteiro)
#   --scale S                 fator de escala do render (default 1)
#   --line W                  espessura do contorno em stroke/trim (default 2)
#
# Pra comparar com a imagem original, use --canvas com o tamanho dela e --frame com a
# bbox do glifo (é o que o compare.py espera).
set -eu
SHAPE_FILE=$1; SHAPE_NAME=$2; OUT=$3; shift 3
MODE=fill; TRIM=1; CW=1254; CH=1254; FX=""; FY=""; FW=""; FH=""; SCALE=1; LINE=2
while [[ $# -gt 0 ]]; do
  case $1 in
    --mode) MODE=$2; shift 2;;
    --trim) TRIM=$2; shift 2;;
    --canvas) CW=$2; CH=$3; shift 3;;
    --frame) FX=$2; FY=$3; FW=$4; FH=$5; shift 5;;
    --scale) SCALE=$2; shift 2;;
    --line) LINE=$2; shift 2;;
    *) echo "opção desconhecida: $1"; exit 2;;
  esac
done
[[ -z $FX ]] && { FX=0; FY=0; FW=$CW; FH=$CH; }

TMP=$(mktemp -d)
# tira o #Preview (macro não compila fora do Xcode) e o `public` não atrapalha
sed '/^#Preview/,/^}/d' "$SHAPE_FILE" > "$TMP/main.swift"
cat >> "$TMP/main.swift" <<EOF

import AppKit
@MainActor func renderShape() {
    let shape = AnyShape($SHAPE_NAME())
    let mode = "$MODE"
    let content = ZStack(alignment: .topLeading) {
        Color.black
        Group {
            if mode == "fill" {
                shape.fill(Color.white)
            } else if mode == "stroke" {
                shape.stroke(Color.white, lineWidth: $LINE)
            } else {
                shape.trim(from: 0, to: $TRIM)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: $LINE, lineCap: .round, lineJoin: .round))
            }
        }
        .frame(width: $FW, height: $FH)
        .offset(x: $FX, y: $FY)
    }
    .frame(width: $CW, height: $CH)
    let renderer = ImageRenderer(content: content)
    renderer.scale = $SCALE
    guard let cg = renderer.cgImage else { fatalError("render falhou") }
    let data = NSBitmapImageRep(cgImage: cg).representation(using: .png, properties: [:])!
    try! data.write(to: URL(fileURLWithPath: "$OUT"))
    print("ok -> $OUT")
}
MainActor.assumeIsolated { renderShape() }
EOF
swiftc -O -o "$TMP/render" "$TMP/main.swift" 2>&1 | grep -E "error" && exit 1
"$TMP/render"
rm -rf "$TMP"

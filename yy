document.getElementById('convert').addEventListener('click', () => {
  const fileInput = document.getElementById('upload');
  if (!fileInput.files.length) {
    alert("Lütfen bir resim seçin!");
    return;
  }

  const reader = new FileReader();
  reader.onload = function(e) {
    const img = new Image();
    img.src = e.target.result;
    img.onload = function() {
      // Canvas üzerine çiz
      const canvas = document.createElement('canvas');
      canvas.width = img.width;
      canvas.height = img.height;
      const ctx = canvas.getContext('2d');
      ctx.drawImage(img, 0, 0);

      // Potrace ile bitmap -> SVG
      const bitmap = ctx.getImageData(0,0,img.width,img.height);
      const svg = Potrace.trace(bitmap); // Simplified for demo

      // SVG preview
      document.getElementById('preview').innerHTML = svg;

      // SVG -> basit G-code
      const gcode = svgToGcode(svg);

      // G-code indir linki
      const blob = new Blob([gcode], {type: 'text/plain'});
      const url = URL.createObjectURL(blob);
      const download = document.getElementById('download');
      download.href = url;
      download.download = 'drawing.gcode';
      download.style.display = 'inline';
      download.textContent = 'G-code İndir';
    }
  }
  reader.readAsDataURL(fileInput.files[0]);
});

// Basit SVG -> G-code çevirici (demo)
function svgToGcode(svg) {
  // Çok basit: sadece X-Y koordinatlarını alıp G1 ile yazıyoruz
  let gcode = "G21 ; mm units\nG90 ; absolute positioning\n";
  const paths = svg.match(/M[\d.,\s]+/g) || [];
  paths.forEach(path => {
    const coords = path.slice(1).trim().split(/[\s,]+/);
    for (let i=0;i<coords.length;i+=2) {
      gcode += `G1 X${coords[i]} Y${coords[i+1]}\n`;
    }
  });
  gcode += "M2 ; end of program";
  return gcode;
}

# Builds BattleSense/copy/timer/ZJTBAR.BAM, the Timer module's portrait bars.
#
# One sequence per bar color, in the order of ZJBarColors_Colors in ZJBarCol.lua, (sequence = option value - 1).
# Every sequence has 91 frames of 2x90 pixels: frame N has its bottom N rows filled.
# The RGB values below must match the ones in ZJBarCol.lua, which colors the Creature Info popup's bars.
#
# Run from anywhere: powershell -ExecutionPolicy Bypass -File tools\make-bar-bam.ps1

$colors = [byte[][]]@(
	[byte[]](230, 0,   0  ), # Red
	[byte[]](255, 145, 0  ), # Orange
	[byte[]](255, 225, 0  ), # Yellow
	[byte[]](0,   210, 0  ), # Green
	[byte[]](0,   225, 225), # Cyan
	[byte[]](40,  110, 255), # Blue
	[byte[]](175, 80,  255), # Purple
	[byte[]](255, 100, 200)  # Pink
)

$source = @'
using System; using System.IO; using System.Text;
public static class ZJBarBam {
	public static int Make(string outPath, byte[][] colors) {
		const int frameCount = 91, w = 2, h = 90, n = w * h;
		int colorCount = colors.Length, total = frameCount * colorCount;
		int frameEntries = 24, cycles = frameEntries + total * 12, palette = cycles + colorCount * 4;
		int lookup = palette + 1024, data = lookup + total * 2;
		var o = new byte[data + total * n];

		Encoding.ASCII.GetBytes("BAM V1  ").CopyTo(o, 0);
		BitConverter.GetBytes((ushort)total).CopyTo(o, 8);
		o[10] = (byte)colorCount;
		o[11] = 0; // RLE color, unused: every frame is stored uncompressed
		BitConverter.GetBytes(frameEntries).CopyTo(o, 12);
		BitConverter.GetBytes(palette).CopyTo(o, 16);
		BitConverter.GetBytes(lookup).CopyTo(o, 20);

		// Palette (BGRA): 0 = transparent green, 1 + c = color c
		o[palette + 1] = 255;
		for (int c = 0; c < colorCount; c++) {
			int q = palette + (c + 1) * 4;
			o[q] = colors[c][2]; o[q + 1] = colors[c][1]; o[q + 2] = colors[c][0];
		}

		for (int c = 0; c < colorCount; c++) {
			BitConverter.GetBytes((ushort)frameCount).CopyTo(o, cycles + c * 4);
			BitConverter.GetBytes((ushort)(c * frameCount)).CopyTo(o, cycles + c * 4 + 2);
			for (int f = 0; f < frameCount; f++) {
				int i = c * frameCount + f, e = frameEntries + i * 12, p = data + i * n;
				BitConverter.GetBytes((ushort)w).CopyTo(o, e);
				BitConverter.GetBytes((ushort)h).CopyTo(o, e + 2);
				BitConverter.GetBytes((uint)p | 0x80000000u).CopyTo(o, e + 8);
				for (int y = h - f; y < h; y++) for (int x = 0; x < w; x++) o[p + y * w + x] = (byte)(c + 1);
				BitConverter.GetBytes((ushort)i).CopyTo(o, lookup + i * 2);
			}
		}

		File.WriteAllBytes(outPath, o);
		return o.Length;
	}
}
'@

Add-Type -TypeDefinition $source
$out = Join-Path $PSScriptRoot "..\BattleSense\copy\timer\ZJTBAR.BAM"
$size = [ZJBarBam]::Make([IO.Path]::GetFullPath($out), $colors)
"Wrote $out ($size bytes)"

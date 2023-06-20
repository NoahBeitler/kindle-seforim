#!/bin/bash


#####
# directories
#####
startpoint="Derekh_Mitzvotekha"
scripts="./scripts/$startpoint"
css="$scripts/$startpoint.css"
intermediate="./intermediate/$startpoint"
source="./sefaria"
output="./output/$startpoint"
gematriya="$source/gematriya.js"
parsha=("Pekudei" "Vayikra" "Tzav" "Shmini" "Tazria" "Metzora" "Achrei Mot" "Kedoshim" "Emor" "Behar" "Bechukotai" "Bamidbar" "Nasso" "Beha'alotcha" "Sh'lach" "Korach" "Chukat" "Balak" "Pinchas" "Matot" "Masei" "Devarim" "Vaetchanan" "Eikev" "Re'eh" "Ki Teitzei" "Ki Tavo" "Nitzavim" "Rosh Hashanah" "Shabbat Shuvah" "Yom Kippur" "Ha'Azinu" "Sukkot" "Shemini Atzeret" "V'Zot HaBerachah" "Shir HaShirim")

convertsefer() {

	input=$1
	folderout=$2
	fileout=$3
	ext=$4
	args=("$input" "$folderout$fileout.$ext" --subset-embedded-fonts --extra-css "$css" --chapter '//*[name()="h2"]' --chapter-mark "none" --language "he" --base-font-size "16" --authors 'רב שניאור זלמן מליאדי' --toc-title "תוכן ענינים" --comments ', via sefaria & Kehot Publication Society' --sr1-replace '<br>' --page-breaks-before '/')
	if [[ $ext == "epub" ]]; then args+=(--no-default-epub-cover); fi;
	if [[ $5 == "embed" ]]; then args+=(--embed-font-family "SBL Hebrew"); fi;
	ebook-convert "${args[@]}"
}

if [[ ! -d "$intermediate" ]]; then mkdir -p "$intermediate"; fi;
for i in ${parsha[@]}; do
	apiname="$startpoint,_$i"
if [[ ! -d "$intermediate" ]]; then mkdir -p "$intermediate"; fi;
	if [[ ! -f "$intermediate/$startpoint.json" ]]; then
		wget -O "$intermediate/$startpoint.json" "https://www.sefaria.org/api/texts/$startpoint?pad=0&vhe=Kehot_Publication_Society";
	fi;

for i in $intermediate/*.json; do
	dest="$(basename --suffix .json $i)"
	node "$scripts/$startpoint.js" "$i" "../../$source/gematriya.js" > "$intermediate/$dest.html"
done

if [[ ! -d "$output/kindle" ]]; then mkdir -p "$output/kindle"; fi;
if [[ ! -d "$output/epub" ]]; then mkdir -p "$output/epub"; fi;

for i in $intermediate/*.html; do
	name=$(basename --suffix=.html $i)
	convertsefer "$i" "$output/kindle/" "$name" "azw3" &
	convertsefer "$i" "$output/epub/" "$name" "epub" &
	wait
done
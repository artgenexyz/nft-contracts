(() => {
    let dna = new URLSearchParams(window.location.search).get("dna");

    if (!dna) {
        /* example: 0xde4b0d963091d3b0a9c9604784c0d9df49e4261df639643cc07185e78bb930ab */
        /* random 64 chars of abcd...1234 in hex */
        dna =
            "0x" +
            Array(64)
            .fill(0)
            .map((_) => "0123456789abcdef" [(Math.random() * 16) | 0])
            .join("");
    }
    window.dna = dna;

    const Artgene = {}; /* namespace */

    /* shuffling images, seed from DNA string */
    /* https://stackoverflow.com/questions/521295/seeding-the-random-number-generator-in-javascript */

    function xmur3(str) {
        for (var i = 0, h = 1779033703 ^ str.length; i < str.length; i++) {
            h = Math.imul(h ^ str.charCodeAt(i), 3432918353);
            h = (h << 13) | (h >>> 19);
        }
        return function () {
            h = Math.imul(h ^ (h >>> 16), 2246822507);
            h = Math.imul(h ^ (h >>> 13), 3266489909);
            return (h ^= h >>> 16) >>> 0;
        };
    }

    function sfc32(a, b, c, d) {
        return function () {
            a |= 0;
            b |= 0;
            c |= 0;
            d |= 0;
            var t = (((a + b) | 0) + d) | 0;
            d = (d + 1) | 0;
            a = b ^ (b >>> 9);
            b = (c + (c << 3)) | 0;
            c = (c << 21) | (c >>> 11);
            c = (c + t) | 0;
            return (t >>> 0) / 4294967296;
        };
    }

    const hash = xmur3(dna);

    console.log("USING DNA:", dna, ", HASH:", hash());

    /* Pad seed with Phi, Pi and E. */
    /* https://en.wikipedia.org/wiki/Nothing-up-my-sleeve_number */
    const _rand = sfc32(0x9e3779b9, 0x243f6a88, 0xb7e15162, hash());

    window.rendered = false;
    const preview = () => {
        console.log("TRIGGER PREVIEW");
        window.rendered = true;
    };

    /* rand(a) should return [0,a]; rand(a,b) should return [a,b] */
    window.rand = (a, b) => {
        if (a === undefined) {
            return _rand();
        } else if (b === undefined) {
            return _rand() * a;
        } else {
            return _rand() * (b - a) + a;
        }
    };

    window.preview = preview;

    /* for compatibility */
    window.fxrand = rand;
    window.fxpreview = preview;

    window.genome = [];

    const evolve = (name, value) => {
        const genome = window.genome;
        const gene = genome.find((g) => g.name === name);

        if (!gene) {
            genome.push({
                name,
                value,
            });
        } else {
            gene.value = value;
        }

        return {
            name,
            value,
        };
    };

    Artgene.evolve = evolve;
    Artgene.rand = rand;
    Artgene.preview = preview;
    Artgene.genome = window.genome;

    window.Artgene = Artgene;
})(window);
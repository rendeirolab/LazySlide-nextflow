# LazySlide with nextflow for WSI preprocessing

The script offers
- [x] Find tissue + Tile tissue
- [ ] QC tisssue and tiles
- [x] Feature extraction (multiple models)
- [x] Aggregation of features


## Usage

1. Install LazySlide

Make sure lazyslide is available in your current shell environment.

Try to execute `lazyslide` to see if it's available.

2. Install nextflow

See the [offical website](https://www.nextflow.io/docs/stable/install.html)

Or you can install with conda or mamba `conda install bioconda::nextflow`

3. Setup sample data (optional)

Clone this repo:

```shell
git clone xxx
```

Assume you are in the root of the repo, now run

```shell
sh scripts/setup_sample_data.sh your_data_dir
# Or you can have a larger dataset
sh scripts/setup_gtex_gastris_data.sh your_data_dir
```

4. Run the script

```shell
nextflow run rendeirolab/lazyslide-nextflow 
    \ --input your_data_dir/input.csv 
    \ --tile_px 256 
    \ --models 'alexnet,resnet50,uni'




updates stable linux kernel source retrieved from S3

TODO: Move to pigz, or xz
    tar -cf dir.tar.gz -I pigz dir
    tar -xf dir.tar.gz -I pigz
 = or xz
    XZ_OPT=-T0 tar -cJf dir.tar.gz dir
    XZ_OPT=-T0 tar -xJf dir.tar.gz

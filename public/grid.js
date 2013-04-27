// Code "inspired" by github.com/qiao/PathFinding.js
function Grid(width, height) {
    this.width = width;
    this.height = height;
    this.nodes = this.generateAll();
}

Grid.prototype.generateAll = function() {
    var nodes = new Array(width);
    var i, j;
    for (i = 0; i < width; i++) {
        nodes[i] = new Array(height);
        for (j = 0; j < height; j++) {
            nodes[i][j] = new Node(i, j);
        }
    }
    return nodes;
}

Grid.prototype.getNodeAt = function(x, y) {
    if (x < 0 || x >= this.width || y < 0 || y >= this.height)
        return {occupied: false};
    return this.nodes[x][y];
}

Grid.prototype.isOccupied = function(x, y) {
    return this.getNodeAt(x, y).occupied;
}

/**
 * Doesn't technically guarantee safety... Just checks whether any
 * neighboring cell is 'occupied'. */
Grid.prototype.isUnsafe = function(x, y) {
    return this.getNodeAt(x,y).occupied ||
           this.getNodeAt(x-1,y).occupied ||
           this.getNodeAt(x+1,y).occupied ||
           this.getNodeAt(x,y+1).occupied ||
           this.getNodeAt(x-1,y+1).occupied ||
           this.getNodeAt(x+1,y+1).occupied ||
           this.getNodeAt(x,y-1).occupied ||
           this.getNodeAt(x-1,y-1).occupied ||
           this.getNodeAt(x+1,y-1).occupied;
}

function Node(xpos, ypos, occupied) {
    this.x = xpos;
    this.y = ypos;
    this.occupied = occupied || false;
}

module.exports = Node

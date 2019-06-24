#------------------------------------------------------------------------------
# All varibles in test environment
#------------------------------------------------------------------------------

variable "organisation"     { default = "clark"   }
variable "account"          { }
variable "env"          	{ }
variable "grp"                  				{ }
variable "cidr_block"       { }

variable "zone"				{ }

variable "tier1cidr" {
  type = "map"
}

variable "tier2cidr" {
  type = "map"
}

variable "tier3cidr" {
  type = "map"
}


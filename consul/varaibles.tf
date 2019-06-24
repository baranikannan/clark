#------------------------------------------------------------------------------
# All Variables defined here
#------------------------------------------------------------------------------

variable "organisation"     { default = "clark"   }
variable "account"          { }

variable "project"              { default = "consul"  }

variable "env"                  { }

variable "key_name"             { }

variable "s3-bucket"             { }

variable "app_version"          { default = "0.0.1"						}
variable "stackMinSize"         { default = "1"             			}
variable "stackMaxSize"         { default = "1"             			}
variable "stackDesiredSize"     { default = "1"             			}
variable "instance_type"        { default = "m4.large"      			}


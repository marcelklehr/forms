<!--
  - @copyright Copyright (c) 2018 René Gieling <github@dartcafe.de>
  -
  - @author René Gieling <github@dartcafe.de>
  - @author Natalie Gilbert
  - @author Nick Gallo
  -
  - @license GNU AGPL version 3 or any later version
  -
  - This program is free software: you can redistribute it and/or modify
  - it under the terms of the GNU Affero General Public License as
  - published by the Free Software Foundation, either version 3 of the
  - License, or (at your option) any later version.
  -
  - This program is distributed in the hope that it will be useful,
  - but WITHOUT ANY WARRANTY; without even the implied warranty of
  - MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  - GNU Affero General Public License for more details.
  -
  - You should have received a copy of the GNU Affero General Public License
  - along with this program.  If not, see <http://www.gnu.org/licenses/>.
  -
  -->

<template>
	<div v-if="header" class="wrapper group-master table-row table-header">
		<div class="wrapper group-1">
			<div class="wrapper group-1-1">
				<div class="name">
					{{ t('forms', 'Title') }}
				</div>
			</div>
		</div>
		<div class="wrapper group-2">
			<div class="wrapper-group-2-5">
				<div class="deletetwo">
					{{ t('forms',"Delete Form") }}
				</div>
			</div>
			<div class="wrapper-group-2-5">
				<div class="copyL">
					{{ t('forms', "Copy Link") }}
				</div>
			</div>
			<div class="wrapper-group-2-5">
				<div class="result">
					{{ t('forms', "View Results") }}
				</div>
			</div>
			<div class="wrapper group-2-1">
				<div class="access">
					{{ t('forms', 'Access') }}
				</div>
			</div>
			<div class="owner">
				{{ t('forms', 'Owner') }}
			</div>
			<div class="wrapper group-2-2">
				<div class="created">
					{{ t('forms', 'Created') }}
				</div>
				<div class="expiry">
					{{ t('forms', 'Expires') }}
				</div>
			</div>
		</div>
	</div>

	<div v-else class="wrapper table-row table-body group-master">
		<div class="wrapper group-1">
			<div>
				<img class="icontwo">
			</div>
			<div class="symbol icon-voted" />
			<a :href="voteUrl" class="wrapper group-1-1">
				<div class="name">
					{{ form.event.title }}
				</div>
				<div class="description">
					{{ form.event.description }}
				</div>
			</a>
		</div>
		<div class="wrapper group-2">
			<div class="wrapper group-2-8">
				<a class="icon icon-delete svg delete-form" @click="deleteForm" />
			</div>
			<div class="wrapper group-2-9">
				<a class="icon icon-clippy svg delete-form" @click="copyLink" />
			</div>
			<div class="list-results wrapper">
				<button class="button btn primary" @click="viewResults">
					<span>{{ "View Results" }}</span>
				</button>
			</div>

			<div class="wrapper group-2-1">
				<div v-tooltip="accessType" class="thumbnail access" :class="form.event.access">
					{{ accessType }}
				</div>
			</div>
			<div class="owner">
				<user-div :user-id="form.event.owner" :display-name="form.event.ownerDisplayName" />
			</div>
			<div class="wrapper group-2-2">
				<div class="created ">
					{{ timeSpanCreated }}
				</div>
				<div class="expiry" :class="{ expired : form.event.expired }">
					{{ timeSpanExpiration }}
				</div>
			</div>
		</div>
	</div>
</template>

<script>
import moment from 'moment'

export default {
	props: {
		header: {
			type: Boolean,
			default: false
		},
		form: {
			type: Object,
			default: undefined
		}
	},

	data() {
		return {
			openedMenu: false,
			hostName: this.$route.query.page
		}

	},

	computed: {
		accessType() {
			if (this.form.event.access === 'public') {
				return t('forms', 'Public access')
			} else if (this.form.event.access === 'select') {
				return t('forms', 'Only shared')
			} else if (this.form.event.access === 'registered') {
				return t('forms', 'Registered users only')
			} else if (this.form.event.access === 'hidden') {
				return t('forms', 'Hidden form')
			} else {
				return ''
			}
		},

		formType() {
			if (this.form.event.type === 'textForm') {
				// TRANSLATORS This means that this is the type of the form. Another type is a 'date form'.
				return t('forms', 'Text form')
			} else {
				// TRANSLATORS This means that this is the type of the form. Another type is a 'text form'.
				return t('forms', 'Text form')
			}
		},

		timeSpanCreated() {
			return moment(this.form.event.created, 'YYYY-MM-DD HH:mm')
		},

		timeSpanExpiration() {
			if (this.form.event.expiration) {
				return moment(this.form.event.expirationDate)
			} else {
				return t('forms', 'never')
			}
		},

		countShares() {
			return this.form.shares.length
		},

		voteUrl() {
			return OC.generateUrl('apps/forms/form/') + this.form.event.hash
		}

	},

	methods: {
		toggleMenu() {
			this.openedMenu = !this.openedMenu
		},

		hideMenu() {
			this.openedMenu = false
		},

		copyLink() {
			// this.$emit('copyLink')
			this.$copyText(window.location.origin + this.voteUrl).then(
				function(e) {
					OC.Notification.showTemporary(t('forms', 'Link copied to clipboard'))
				},
				function(e) {
					OC.Notification.showTemporary(t('forms', 'Error, while copying link to clipboard'))
				}
			)
			this.hideMenu()
		},

		deleteForm() {
			this.$emit('deleteForm')
		},

		viewResults() {
			this.$emit('viewResults')
		}
	}
}
</script>
<style lang="scss">
$row-padding: 15px;
$table-padding: 4px;

$date-width: 130px;
$participants-width: 95px;
$group-2-2-width: max($date-width, $participants-width);

$owner-width: 140px;
$access-width: 44px;
$group-2-1-width: max($access-width, $date-width);
$group-2-width: $owner-width + $group-2-1-width + $group-2-2-width;

$action-width: 44px;
$thumbnail-width: 44px;
$thumbnail-icon-width: 32px;
$name-width: 150px;
$description-width: 150px;
$group-1-1-width: max($name-width, $description-width);
$group-1-width: $thumbnail-width + $group-1-1-width + $action-width;

$group-master-width: max($group-1-width, $group-2-width);

$mediabreak-1: ($group-1-width + $owner-width + $access-width + $date-width + $date-width + $participants-width + $row-padding * 2);
$mediabreak-2: ($group-1-width + $group-2-width + $row-padding * 2);
$mediabreak-3: $group-1-width + $owner-width + max($group-2-1-width, $group-2-2-width) + $row-padding *2 ;

.table-row {
	width: 100%;
	padding-left:  $row-padding;
	padding-right: $row-padding;

	line-height: 2em;
	transition: background-color 0.3s ease;
	background-color: var(--color-main-background);
	min-height: 4em;
	border-bottom: 1px solid var(--color-border);

	&.table-header {
		.name, .description {
			padding-left: ($thumbnail-width + $table-padding *2);
		}
		.owner {
			padding-left: 6px;
		}
	}

	&.table-body {
		&:hover, &:focus, &:active, &.mouseOver {
			transition: background-color 0.3s ease;
			background-color: var(--color-background-dark);
		}
		.icon-more {
			right: 14px;
			opacity: 0.3;
			cursor: pointer;
			height: 44px;
			width: 44px;
		}

		.symbol {
			padding: 2px;
		}

	}

	&.table-header {
		opacity: 0.5;
	}
}

.wrapper {
	display: flex;
	align-items: center;
	position: relative;
	flex-grow: 0;
	div {
	}
}

.name {
	width: $name-width;
}

.description {
	width: $description-width;
	opacity: 0.5;
}

.name, .description {
	overflow: hidden;
	white-space: nowrap;
	text-overflow: ellipsis;
}

.actions {
	width: $action-width;
	position: relative;
	overflow: initial;
}

.result {
  width: 60px;
	padding-right: 15px;
}

.deletetwo {
  width: 60px;
	padding-right: 15px;
}
.copyL {
	width: 60px;
	padding-right: 15px;
}

.access {
	width: $access-width;
}

.owner {
	width: $owner-width;
}

.created {
	width: $date-width;
}

.expiry {
	width: $date-width;
	&.expired {
		color: red;
	}
}

.delete-form {
  padding-right:70px;
}

.list-results {
	width: 65px;
}

.group-1, .group-1-1 {
	flex-grow: 1;
}

.group-1-1 {
	flex-direction: column;
	width: $group-1-1-width;
	> div {
		width: 100%;
	}
}

@media all and (max-width: ($mediabreak-1) ) {
	.group-1 {
		width: $group-1-width;
	}
	.group-2-1, .group-2-2 {
		flex-direction: column;
	}

	.created {
		width: $group-2-1-width;;
	}
	.expiry, .participants {
		width: $group-2-2-width;;
	}
}

@media all and (max-width: ($mediabreak-2) ) {
	.table-row {
		padding: 0;
	}

	.group-2-1 {
		display: none;
	}
}

@media all and (max-width: ($mediabreak-3) ) {
	.group-2 {
		display: none;
	}
}

.icontwo {
  width: 44px;
  height: 44px;
  padding-right: 4px;
  font-size: 0;
  background-color: var(--color-text-light);
  mask-image: var(--icon-organization-000) no-repeat 50% 50%;
  -webkit-mask: var(--icon-organization-000) no-repeat 50% 50%;
  mask-size: 16px;
}

.thumbnail {
    width: 44px;
    height: 44px;
    padding-right: 4px;
    font-size: 0;
    background-color: var(--color-text-light);
    &.dateForm {
        mask-image: var(--icon-calendar-000) no-repeat 50% 50%;
        -webkit-mask: var(--icon-calendar-000) no-repeat 50% 50%;
        mask-size: 16px;
    }
    &.textForm {
        mask-image: var(--icon-organization-000) no-repeat 50% 50%;
        -webkit-mask: var(--icon-organization-000) no-repeat 50% 50%;
        mask-size: 16px;
    }
    &.expired {
        background-color: var(--color-background-darker);
    }
    &.access {
        display: inherit;
        &.hidden {
            mask-image: var(--icon-password-000) no-repeat 50% 50%;
            -webkit-mask: var(--icon-password-000) no-repeat 50% 50%;
            mask-size: 16px;
        }
        &.public {
            mask-image: var(--icon-link-000) no-repeat 50% 50%;
            -webkit-mask: var(--icon-link-000) no-repeat 50% 50%;
            mask-size: 16px;
        }
        &.select {
            mask-image: var(--icon-share-000) no-repeat 50% 50%;
            -webkit-mask: var(--icon-share-000) no-repeat 50% 50%;
            mask-size: 16px;
        }
        &.registered {
            mask-image: var(--icon-group-000) no-repeat 50% 50%;
            -webkit-mask: var(--icon-group-000) no-repeat 50% 50%;
            mask-size: 16px;
        }

    }
}

.icon-voted {
    background-image: var(--icon-checkmark-fff);
}

.app-navigation-entry-utils-counter {
    padding-right: 0 !important;
    overflow: hidden;
    text-align: right;
    font-size: 9pt;
    line-height: 44px;
    padding: 0 12px;
    // min-width: 25px;
    &.highlighted {
        padding: 0;
        text-align: center;
        span {
            padding: 2px 5px;
            border-radius: 10px;
            background-color: var(--color-primary);
            color: var(--color-primary-text);
        }
    }
}

.symbol.icon-voted {
    position: absolute;
    left: 11px;
    top: 16px;
    background-size: 0;
    min-width: 8px;
    min-height: 8px;
    background-color: var(--color-success);
    border-radius: 50%;
}
</style>
